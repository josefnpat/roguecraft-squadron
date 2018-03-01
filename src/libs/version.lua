local version = {}

function version.draw()
  local vs_info = libs.i18n('git.client.info',{git_count=git_count,git_hash=git_hash}).."\n"
  if version_server then
    if version_server.count and version_server.hash then
      vs_info = vs_info .. libs.i18n('git.server.info',{
        git_count=version_server.count,
        git_hash=version_server.hash}).."\n"
    end
    if version_server.message then
      vs_info = vs_info .. libs.i18n('git.server.message')..": ".. tostring(version_server.message).."\n"
    end
    if version_server.error then
      vs_info = vs_info .. libs.i18n('git.server.error') .. ": ".. tostring(version_server.error).."\n"
    end
    if version_server.count > git_count then
      vs_info = vs_info .. libs.i18n('git.behind')
    elseif version_server.count < git_count then
      vs_info = vs_info .. libs.i18n('git.ahead')
    else -- ==
      vs_info = vs_info .. libs.i18n('git.equal')
    end
  end
  dropshadowf(vs_info,
    32,32,love.graphics.getWidth()-64,"left")
end

return version
