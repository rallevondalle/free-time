# Wires the native iOS pieces into Runner.xcodeproj. Idempotent: safe to rerun.
#
# The repo was created on Linux, so the Swift files existed but no target
# compiled them. This adds:
#   - Runner/FreeTimeBridge.swift to the Runner target
#   - App Group + Family Controls entitlements on Runner and the extension
#   - the FreeTimeMonitor DeviceActivity monitor extension, embedded in Runner
#   - the development team on all of them
#
# Run from the repo root (uses the xcodeproj gem bundled with Homebrew CocoaPods):
#   GEM_HOME=$(brew --prefix cocoapods)/libexec \
#     $(brew --prefix ruby)/bin/ruby ios/scripts/setup_targets.rb
# or simply:  ios/scripts/setup_targets.sh

require 'xcodeproj'

IOS = File.expand_path('..', __dir__)
TEAM = 'XFQR9ZD5A3'
APP_GROUP = 'group.dk.rassta.freetime'
EXT_NAME = 'FreeTimeMonitor'
EXT_BUNDLE_ID = 'dk.rassta.freetime.FreeTimeMonitor'
DEPLOYMENT_TARGET = '16.0'

ENTITLEMENTS = <<~PLIST
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
  	<key>com.apple.developer.family-controls</key>
  	<true/>
  	<key>com.apple.security.application-groups</key>
  	<array>
  		<string>#{APP_GROUP}</string>
  	</array>
  </dict>
  </plist>
PLIST

def write_entitlements(rel)
  path = File.join(IOS, rel)
  File.write(path, ENTITLEMENTS) unless File.exist?(path) && File.read(path) == ENTITLEMENTS
end

def ensure_file(group, name)
  group.files.find { |f| f.path == name } || group.new_reference(name)
end

project = Xcodeproj::Project.open(File.join(IOS, 'Runner.xcodeproj'))
runner = project.targets.find { |t| t.name == 'Runner' }
runner_group = project.main_group['Runner']

# --- Runner ---------------------------------------------------------------

bridge = ensure_file(runner_group, 'FreeTimeBridge.swift')
runner.source_build_phase.add_file_reference(bridge, true)

write_entitlements('Runner/Runner.entitlements')
ensure_file(runner_group, 'Runner.entitlements')
runner.build_configurations.each do |c|
  c.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
  c.build_settings['DEVELOPMENT_TEAM'] = TEAM
end

# --- FreeTimeMonitor extension -------------------------------------------

ext = project.targets.find { |t| t.name == EXT_NAME }
unless ext
  ext = project.new_target(:app_extension, EXT_NAME, :ios, DEPLOYMENT_TARGET, nil, :swift)
  # new_target only creates Debug/Release; Flutter also builds Profile.
  unless ext.build_configuration_list['Profile']
    profile = ext.add_build_configuration('Profile', :release)
    profile.build_settings.merge!(ext.build_configuration_list['Release'].build_settings)
  end
end

ext_group = project.main_group[EXT_NAME] || project.main_group.new_group(EXT_NAME, EXT_NAME)
ext_src = ensure_file(ext_group, 'DeviceActivityMonitorExtension.swift')
ensure_file(ext_group, 'Info.plist')
write_entitlements("#{EXT_NAME}/#{EXT_NAME}.entitlements")
ensure_file(ext_group, "#{EXT_NAME}.entitlements")
ext.source_build_phase.add_file_reference(ext_src, true)

# Same Flutter xcconfigs as Runner, so FLUTTER_BUILD_NAME/NUMBER match the app
# (App Store rejects an extension whose version differs from its host).
runner_xcconfigs = runner.build_configurations.to_h { |c| [c.name, c.base_configuration_reference] }
ext.build_configurations.each do |c|
  c.base_configuration_reference = runner_xcconfigs[c.name]
  s = c.build_settings
  s['PRODUCT_BUNDLE_IDENTIFIER'] = EXT_BUNDLE_ID
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['INFOPLIST_FILE'] = "#{EXT_NAME}/Info.plist"
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['INFOPLIST_KEY_CFBundleDisplayName'] = EXT_NAME
  s['MARKETING_VERSION'] = '$(FLUTTER_BUILD_NAME)'
  s['CURRENT_PROJECT_VERSION'] = '$(FLUTTER_BUILD_NUMBER)'
  s['CODE_SIGN_ENTITLEMENTS'] = "#{EXT_NAME}/#{EXT_NAME}.entitlements"
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['DEVELOPMENT_TEAM'] = TEAM
  s['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT_TARGET
  s['SWIFT_VERSION'] = '5.0'
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['SKIP_INSTALL'] = 'YES'
  s['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

# Embed the .appex in Runner.
runner.add_dependency(ext) unless runner.dependencies.any? { |d| d.target == ext }
embed = runner.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' }
unless embed
  embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
  embed.symbol_dst_subfolder_spec = :plug_ins
end
unless embed.files_references.include?(ext.product_reference)
  bf = embed.add_file_reference(ext.product_reference, true)
  bf.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
end
# Must run before Flutter's "Thin Binary" script, or Xcode reports a build cycle.
thin = runner.build_phases.find { |p| p.respond_to?(:name) && p.name == 'Thin Binary' }
if thin
  runner.build_phases.delete(embed)
  runner.build_phases.insert(runner.build_phases.index(thin), embed)
end

project.save
puts 'Runner.xcodeproj updated'
