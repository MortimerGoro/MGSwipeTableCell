Pod::Spec.new do |s|
  s.name     = 'MGSwipeTableCell'
  s.version  = '1.5.3'
  s.author   = { 'Imanol Fernandez' => 'mortimergoro@gmail.com' }
  s.homepage = 'https://github.com/MortimerGoro/MGSwipeTableCell'
  s.summary  = 'An easy to use UITableViewCell subclass that allows to display swipeable buttons with a variety of transitions'
  s.license  = 'MIT'
  s.source   = { :git => 'https://github.com/MortimerGoro/MGSwipeTableCell.git', :tag => s.version.to_s }
  s.source_files = 'MGSwipeTableCell'
  s.platform = :ios
  s.ios.deployment_target = '5.0'
  s.requires_arc = true
end
