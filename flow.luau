local files={}local function convertToFullPath(basePath,relativePath)local
baseSegments={}local relativeSegments={}for segment in string.gmatch(basePath,
'([^/]+)')do if segment=='.'then table.insert(baseSegments,'')else table.insert(
baseSegments,segment)end end for segment in string.gmatch(relativePath,'([^/]+)'
)do if segment=='.'then table.insert(relativeSegments,'')else table.insert(
relativeSegments,segment)end end while#relativeSegments>0 and relativeSegments[1
]=='..'do table.remove(relativeSegments,1)table.remove(baseSegments,#
baseSegments)end local fullPath=table.concat(baseSegments,'/')fullPath..=(if
fullPath==''then''else'/')..table.concat(relativeSegments,'/')return fullPath
end local function customRequire(target)local module=files[target]if module.
isLoaded then return module.value else local data=module.fn()module.value=data
return data end end local function newEnv(id)return setmetatable({require=
function(target)local fullpath=convertToFullPath(id,target)if files[fullpath]
then return customRequire(fullpath)else return require(target)end end},{__index=
getfenv(0),__metatable='This metatable is locked'})end local function newFile(
path,fn)files[path]={fn=fn,isLoaded=false,value=nil}end local function init()
local main=files['LuneFlow/main']if main then main.value=main.fn()main.isLoaded=
true end end newFile('LuneFlow/commands/download-assets',function()return
setfenv(function()local fs=require('@lune/fs')local serde=require('@lune/serde')
local roblox=require('@lune/roblox')local outputUtils=require(
'../utils/output-utils')local validateUtils=require('../utils/validate-utils')
local fileUtils=require('../utils/file-utils')local remodel=require(
'../utils/remodel')local richPrint,createBar,createSpinner=outputUtils.richPrint
,outputUtils.createBar,outputUtils.createSpinner return{['priority']=3,[
'command']='download-assets',['display']='Download Assets',['run']=function()
local spinner=createSpinner()richPrint('blue','bold',
'\u{2699}\u{fe0f}  Reading assets config file...')fileUtils.ensureFileExists(
'assets.config.toml',
'\u{274c} No assets.config.toml file found.\nRun `lune flow generate-config` to generate a template file.'
)spinner.setText('Validating assets.config.toml...')spinner.start()local config=
serde.decode('toml',fs.readFile('assets.config.toml'))validateUtils.
validateAssets(config)spinner.stop()richPrint('blue','dim',
'Validated assets configuration!')local downloadProgressBar=createBar()local
totalAssets=#config.assets richPrint('blue','bold',
'\u{1f528} Processing source code...')for index,assetData in config.assets do
downloadProgressBar.setPercent(index/totalAssets)downloadProgressBar.setText((
'Downloading asset %q...'):format(assetData.id))downloadProgressBar.render()if
assetData.type=='Place'and next(assetData.extract)then local asset=remodel.
readPlaceAsset(assetData.id)if not asset then error(('Failed to fetch place %q')
:format(assetData.id))end for _,parent in asset:GetChildren()do if assetData.
extract and table.find(assetData.extract,parent.Name)==nil then continue end for
_,instance in parent:GetChildren()do remodel.createDirAll(string.format('%s/%s',
assetData.output,parent.Name))remodel.writeModelFile(string.format(
'%s/%s/%s.rbxmx',assetData.output,parent.Name,instance.Name),instance)end end
elseif assetData.type=='Asset'then local model=remodel.readModelAsset(assetData.
id)if not model or not next(model)then error(('Failed to fetch asset %q'):
format(assetData.id))end local asset=roblox.Instance.new('Model')for _,instance
in model do instance.Parent=asset end remodel.createDirAll(assetData.output)
local placeFile=roblox.serializeModel(model,true)fs.writeFile(string.format(
'%s/%s.rbxmx',assetData.output,assetData.Name or assetData.id),placeFile)end
downloadProgressBar.clear()end end}end,newEnv('LuneFlow/commands'))()end)
newFile('LuneFlow/commands/generate-config',function()return setfenv(function()
local fs=require('@lune/fs')local stdio=require('@lune/stdio')local outputUtils=
require('../utils/output-utils')return{['priority']=3,['command']=
'generate-config',['display']='Generate Config',['run']=function()local
overrideConfig,overrideAssets local isFileConfig,isFileAssets=fs.isFile(
'project.config.toml'),fs.isFile('assets.config.toml')if isFileConfig then
overrideConfig=stdio.prompt('confirm',
[[Would you like to override project.config.toml with a template file?]])end if
overrideConfig or not isFileConfig then outputUtils.richPrint('green','bold',
'\u{2699}\u{fe0f}  Generating a template project.config.toml file!\n')fs.
writeFile('project.config.toml',table.concat({'[auth]','publishKey = "API_KEY"',
'messageKey = "API_KEY"','','[shutdown]','topic = "ShutdownTrigger"',
'defaultMessage = "Servers are updating, please wait!"',
'packetTemplate = "$MESSAGE"','','[tests]','runner = "tests/runner.lua"',
'project = "tests.project.json"','output = "tests.rbxl"','','[places.default]',
'project = "default.project.json"','output = "default.rbxl"','',
'[places.default.environments]','Testing = "universeId/placeId"',
'Staging = "universeId/placeId"','Production = "universeId/placeId"',''},'\n'))
end local createAssets if isFileAssets then overrideAssets=stdio.prompt(
'confirm',
[[Would you like to override assets.config.toml with a template file?]])else
createAssets=stdio.prompt('confirm',
[[Would you like to create a template assets.config.toml file?]])end if
overrideAssets or createAssets then outputUtils.richPrint('green','bold',
'\u{2699}\u{fe0f}  Generating a template assets.config.toml file!\n')fs.
writeFile('assets.config.toml',table.concat({'[[assets]]','id = 1818',
'type = "Place"','extract = [ "Workspace" ]',
'output = "assets/places/crossroads"','','[[assets]]','id = 53326',
'type = "Asset"','output = "assets/models"'},'\n'))end end}end,newEnv(
'LuneFlow/commands'))()end)newFile('LuneFlow/commands/init',function()return
setfenv(function()return{require('release'),require('generate-config'),require(
'download-assets')}end,newEnv('LuneFlow/commands'))()end)newFile(
'LuneFlow/commands/release old',function()return setfenv(function()local stdio=
require('@lune/stdio')local fs=require('@lune/fs')local net=require('@lune/net')
local serde=require('@lune/serde')local process=require('@lune/process')local
outputUtils=require('../utils/output-utils')local validateUtils=require(
'../utils/validate-utils')local fileUtils=require('../utils/file-utils')local
richPrint,createBar,createSpinner=outputUtils.richPrint,outputUtils.createBar,
outputUtils.createSpinner return{['priority']=0,['command']='release',['display'
]='Release Game',['run']=function()local spinner=createSpinner()richPrint('blue'
,'bold','\u{2699}\u{fe0f}  Reading config file...')fileUtils.ensureFileExists(
'project.config.toml',
'\u{274c} No project.config.toml file found.\nRun `lune flow generate-config` to generate a template file.'
)spinner.setText('Validating project.config.toml...')spinner.start()local config
=serde.decode('yaml',fs.readFile('project.config.toml'))validateUtils.
validateConfig(config)spinner.stop()richPrint('blue','dim',
'Validated release configuration!')richPrint('blue','bold',
'\u{1f6e0}\u{fe0f}  Reading project file...')fileUtils.ensureFileExists(config.
build.project,"\u{274c} Could not find project file '"..config.build.project..
[['. Please ensure your project.config.toml file contains a valid project file path.]]
)spinner.setText('Parsing '..config.build.project..'...')spinner.start()local
pathsUsedByProject=fileUtils.readPathsFromProject(config.build.project)spinner.
stop()richPrint('blue','dim','Found '..#pathsUsedByProject..
' paths used in project!')richPrint('blue','bold',
'\u{1f4be} Reading version control info...')local latestCommitHash=string.gsub(
process.spawn('git',{'log','--pretty=format:%h','-n','1'}).stdout,'\n$','')local
gitBranch=string.gsub(process.spawn('git',{'branch','--show-current'}).stdout,
'\n$','')local gitStatus=string.split(string.gsub(process.spawn('git',{'status',
'--porcelain'}).stdout,'\n$',''),'\n')validateUtils.validateGitStatus(gitStatus,
pathsUsedByProject,{'project.config.toml',config.build.project})richPrint('blue'
,'dim','All necessary files are committed and ready!')if fs.isFile('wally.toml')
then richPrint('blue','bold','\u{1f4e5} Installing dependencies...')spinner.
setText('Running wally install...')spinner.start()local dependenciesResult=
process.spawn('wally',{'install'})spinner.stop()if dependenciesResult.ok==false
then richPrint('red','bold','Dependency install failure:')richPrint('red',
dependenciesResult.stderr)process.exit(1)return end local packagesInstalled=
string.match(dependenciesResult.stderr,'Downloaded (%d+) packages')or 0
richPrint('blue','dim','Installed '..packagesInstalled..' packages!')end spinner
.stop()richPrint('green','bold',
"\n\u{2705} Looks like we're good to get started!")stdio.write('\n')local
shouldLint=stdio.prompt('confirm','Would you like to run the linter first?')if
shouldLint then local lintTargets=validateUtils.filterThirdPartyPaths(
pathsUsedByProject)richPrint('blue','bold','\u{1f50d} Analyzing '..table.concat(
lintTargets,', ')..'...')local lintResult=process.spawn('selene',{'--config',
'selene.toml',table.unpack(lintTargets)},{stdio='inherit'})if lintResult.ok==
false then process.exit(1)return end stdio.write('\n')end stdio.write('\n')local
shouldTest=stdio.prompt('confirm',
'Would you like to run the test suite before we continue?')if shouldTest then
validateUtils.validateTestsConfig(config)richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Building test file...')local testBuildResult=process.spawn(
'rojo',{'build',config.tests.project,'--output',config.tests.output})if
testBuildResult.ok==false then richPrint('red','bold','Test build failure:')
richPrint('red',testBuildResult.stderr)process.exit(1)return end richPrint(
'blue','bold','\u{1f52c} Running tests...')local testResult=process.spawn(
'run-in-roblox',{'--place',config.tests.output,'--script',config.tests.runner},{
stdio='inherit'})if testResult.ok==false then process.exit(1)return end fs.
removeFile(config.tests.output)end local buildFile=nil stdio.write('\n')local
shouldProcess=stdio.prompt('confirm',
'Do you want to process & minify the source code?')if shouldProcess then local
topLevelPaths={}for _,path in pathsUsedByProject do local topPath=string.match(
path,'^[^/\\]+')topLevelPaths[topPath]=true end local totalFiles,checkedFiles=0,
0 for path in topLevelPaths do totalFiles+=fileUtils.countFiles(path)end
richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Generating processed project file...')local processedProject
=fileUtils.createProjectCopyWithPrefixedPaths(config.build.project,'processed-')
fs.writeFile('processed.project.json',serde.encode('json',processedProject))
local processProgressBar=createBar()richPrint('blue','bold',
'\u{1f528} Processing source code...')local function processFiles(entryName)
local processed,skipped=0,0 if fs.isFile(entryName)then checkedFiles+=1
processProgressBar.setPercent(checkedFiles/totalFiles)processProgressBar.
setText('File '..checkedFiles..': '..(string.match(entryName,'[^/\\]+$')or
entryName)..'...')processProgressBar.render()if string.find(entryName,'%.luau?$'
)then local subEntryProcessResult=process.spawn('darklua',{'process',entryName,
'processed-'..entryName,'--format','retain-lines'})if subEntryProcessResult.ok==
true then processed+=1 else skipped+=1 fs.writeFile('processed-'..entryName,fs.
readFile(entryName))end else skipped+=1 fs.writeFile('processed-'..entryName,fs.
readFile(entryName))end elseif fs.isDir(entryName)then fs.writeDir('processed-'
..entryName)for _,subEntryName in fs.readDir(entryName)do local subProcessed,
subSkipped=processFiles(entryName..'/'..subEntryName)processed+=subProcessed
skipped+=subSkipped end end return processed,skipped end local totalProcessed,
totalSkipped=0,0 for path in topLevelPaths do local pathProcessed,pathSkipped=
processFiles(path)totalProcessed+=pathProcessed totalSkipped+=pathSkipped end
processProgressBar.clear()richPrint('blue','dim','Processed '..totalProcessed..
' files, and left '..totalSkipped..' files as-is!')richPrint('blue','bold',
'\u{1f9fe}Removing story files...')local storyRemovals=0 for path in
topLevelPaths do storyRemovals+=fileUtils.removeFileMatches('processed-'..path,
'[%._]story%.luau?$')end richPrint('blue','dim','Removed '..storyRemovals..
' story files!')richPrint('blue','bold','\u{1f9fe}Removing spec files...')local
specRemovals=0 for path in topLevelPaths do specRemovals+=fileUtils.
removeFileMatches('processed-'..path,'[%._]spec%.luau?$')end richPrint('blue',
'dim','Removed '..specRemovals..' spec files!')richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Building place file...')local buildResult=process.spawn(
'rojo',{'build','processed.project.json','--output',config.build.output})if
buildResult.ok==false then richPrint('red','bold','Build failure:')richPrint(
'red',buildResult.stderr)process.exit(1)return end buildFile=fs.readFile(config.
build.output)richPrint('blue','dim','Built project to `'..config.build.output..
'`!')fs.removeFile('processed.project.json')for path in topLevelPaths do fs.
removeDir('processed-'..path)end else richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Building place file...')local buildResult=process.spawn(
'rojo',{'build',config.build.project,'--output',config.build.output})if
buildResult.ok==false then richPrint('red','bold','Build failure:')richPrint(
'red',buildResult.stderr)process.exit(1)return end buildFile=fs.readFile(config.
build.output)richPrint('blue','dim','Built project to `'..config.build.output..
'`!')end stdio.write('\n')richPrint('green','bold',
"\u{1f3c1} We're nearly ready to publish!")local enviromentOptions={}for envId
in config.environments do table.insert(enviromentOptions,envId)end table.sort(
enviromentOptions)stdio.write('\n')local envChoice=stdio.prompt('select',
'Which environment would you like to publish to?',enviromentOptions)local
envTarget=enviromentOptions[envChoice]local envConfig=config.environments[
envTarget]local shutdownMessage=''stdio.write('\n')local shouldShutdown=stdio.
prompt('confirm',
[[Would you like to soft-shutdown the servers after publishing?]])if
shouldShutdown then stdio.write('\n')shutdownMessage=stdio.prompt('text',
'What message should display during the server restart?',config.shutdown.
defaultMessage)end stdio.write('\n')richPrint('red','dim',
"\u{1f6c2} Let's double check before we publish!")richPrint('white','reset',
string.format('Source Commit: %s@%s',gitBranch,latestCommitHash)..string.format(
'\nEnvironment: %s',envTarget)..string.format('\nBuild File: '..config.build.
output..' (%d KB)',#buildFile/1024)..string.format('\nSoft Shutdown: %s',if
shouldShutdown then'Yes'else'No')..if shouldShutdown then string.format(
'\nShutdown Message: %s',shutdownMessage)else'')stdio.write('\n')local
doubleChecked=stdio.prompt('confirm','Is everything correct?')stdio.write('\n')
if not doubleChecked then richPrint('red','bold',
"\u{1f6d1} Publishing aborted, let's try again later.")process.exit(1)return end
richPrint('blue','bold','\u{1f680} Publishing to '..envTarget..'...')spinner.
setText('Deploying via Open Cloud API...')spinner.start()local universeId,
placeId=string.match(envConfig,'(%d+)/(%d+)')if universeId==nil or placeId==nil
then richPrint('red','bold',
"Could not parse IDs from environment configuration '"..envConfig.."'!")process.
exit(1)return end local publishSuccess,publishResponse=pcall(net.request,{url=
string.format(
[[https://apis.roblox.com/universes/v1/%s/places/%s/versions?versionType=Published]]
,universeId,placeId),method='POST',headers={['x-api-key']=config.auth.publishKey
,['Content-Type']='application/octet-stream'},body=buildFile})spinner.stop()if
publishSuccess==false then richPrint('red','bold','Publish failure:')richPrint(
'red','reset',publishResponse)process.exit(1)return elseif publishResponse.ok==
false then richPrint('red','bold','Publish failure: '..publishResponse.
statusCode..' '..publishResponse.statusMessage)richPrint('red','reset',
publishResponse.body)process.exit(1)return end local body=net.jsonDecode(
publishResponse.body)richPrint('blue','dim',
'Place has been published to place version '..body.versionNumber..'!')if
shouldShutdown then spinner.setText('Sending server shutdown message...')spinner
.start()local sanitizedMessage=string.gsub(shutdownMessage,'"','\\"')local
packet=string.gsub(config.shutdown.packetTemplate,'%$MESSAGE',sanitizedMessage)
local messageSuccess,messageResponse=pcall(net.request,{url=string.format(
[[https://apis.roblox.com/messaging-service/v1/universes/%s/topics/]]..config.
shutdown.topic,universeId),method='POST',headers={['x-api-key']=config.auth.
messageKey,['Content-Type']='application/json'},body=net.jsonEncode({['message']
=packet})})spinner.stop()if messageSuccess==false then richPrint('red','bold',
'Message failure:')richPrint('red','reset',messageResponse)process.exit(1)return
elseif messageResponse.ok==false then richPrint('red','bold',
'Message failure  : '..messageResponse.statusCode..' '..messageResponse.
statusMessage)richPrint('red','reset',messageResponse.body)process.exit(1)return
end richPrint('blue','dim',"Shutdown trigger has been sent with message '"..
shutdownMessage.."'!")end end}end,newEnv('LuneFlow/commands'))()end)newFile(
'LuneFlow/commands/release',function()return setfenv(function()local stdio=
require('@lune/stdio')local fs=require('@lune/fs')local net=require('@lune/net')
local serde=require('@lune/serde')local process=require('@lune/process')local
remodel=require('../utils/remodel')local outputUtils=require(
'../utils/output-utils')local validateUtils=require('../utils/validate-utils')
local fileUtils=require('../utils/file-utils')local richPrint,createBar,
createSpinner=outputUtils.richPrint,outputUtils.createBar,outputUtils.
createSpinner return{['priority']=0,['command']='release',['display']=
'Release Game',['run']=function()local spinner=createSpinner()richPrint('blue',
'bold','\u{2699}\u{fe0f}  Reading config file...')fileUtils.ensureFileExists(
'project.config.toml',
'\u{274c} No project.config.toml file found.\nRun `lune flow generate-config` to generate a template file.'
)spinner.setText('Validating project.config.toml...')spinner.start()local config
=serde.decode('toml',fs.readFile('project.config.toml'))validateUtils.
validateConfig(config)spinner.stop()richPrint('blue','dim',
'Validated release configuration!')richPrint('blue','bold',
'\u{1f6e0}\u{fe0f}  Reading project files...')spinner.start()local
pathsUsedByProject={}local enviromentOptions={}for place,data in config.places
do spinner.setText('Parsing '..data.project..'...')fileUtils.ensureFileExists(
data.project,"\u{274c} Could not find project file '"..data.project..
[['. Please ensure your project.config.toml file contains a valid project file path.]]
)for envId in data.environments do if table.find(enviromentOptions,envId)==nil
then table.insert(enviromentOptions,envId)end end table.sort(enviromentOptions)
for _,v in fileUtils.readPathsFromProject(data.project)do if table.find(
pathsUsedByProject,v)==nil then table.insert(pathsUsedByProject,v)end end end
spinner.stop()richPrint('blue','dim','Found '..#pathsUsedByProject..
' paths used in project!')richPrint('blue','bold',
'\u{1f4be} Reading version control info...')local latestCommitHash=string.gsub(
process.spawn('git',{'log','--pretty=format:%h','-n','1'}).stdout,'\n$','')local
gitBranch=string.gsub(process.spawn('git',{'branch','--show-current'}).stdout,
'\n$','')local gitStatus=string.split(string.gsub(process.spawn('git',{'status',
'--porcelain'}).stdout,'\n$',''),'\n')validateUtils.validateGitStatus(gitStatus,
pathsUsedByProject,{'project.config.toml'})richPrint('blue','dim',
'All necessary files are committed and ready!')if fs.isFile('wally.toml')then
richPrint('blue','bold','\u{1f4e5} Installing dependencies...')spinner.setText(
'Running wally install...')spinner.start()local dependenciesResult=process.
spawn('wally',{'install'})spinner.stop()if dependenciesResult.ok==false then
richPrint('red','bold','Dependency install failure:')richPrint('red',
dependenciesResult.stderr)process.exit(1)return end local packagesInstalled=
string.match(dependenciesResult.stderr,'Downloaded (%d+) packages')or 0
richPrint('blue','dim','Installed '..packagesInstalled..' packages!')end spinner
.stop()richPrint('green','bold',
"\n\u{2705} Looks like we're good to get started!")stdio.write('\n')local
shouldLint=stdio.prompt('confirm','Would you like to run the linter first?')if
shouldLint then local lintTargets=validateUtils.filterThirdPartyPaths(
pathsUsedByProject)richPrint('blue','bold','\u{1f50d} Analyzing '..table.concat(
lintTargets,', ')..'...')local lintResult=process.spawn('selene',{'--config',
'selene.toml',table.unpack(lintTargets)},{stdio='inherit'})if lintResult.ok==
false then process.exit(1)return end stdio.write('\n')end stdio.write('\n')local
shouldTest=stdio.prompt('confirm',
'Would you like to run the test suite before we continue?')if shouldTest then
validateUtils.validateTestsConfig(config)richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Building test file...')local testBuildResult=process.spawn(
'rojo',{'build',config.tests.project,'--output',config.tests.output})if
testBuildResult.ok==false then richPrint('red','bold','Test build failure:')
richPrint('red',testBuildResult.stderr)process.exit(1)return end richPrint(
'blue','bold','\u{1f52c} Running tests...')local testResult=process.spawn(
'run-in-roblox',{'--place',config.tests.output,'--script',config.tests.runner},{
stdio='inherit'})if testResult.ok==false then process.exit(1)return end fs.
removeFile(config.tests.output)end local buildFiles={}stdio.write('\n')local
shouldProcess=stdio.prompt('confirm',
'Do you want to process & minify the source code?')if shouldProcess then local
topLevelPaths={}for _,path in pathsUsedByProject do local topPath=string.match(
path,'^[^/\\]+')topLevelPaths[topPath]=true end local totalFiles,checkedFiles=0,
0 local totalProcessed,totalSkipped=0,0 for path in topLevelPaths do totalFiles
+=fileUtils.countFiles(path)end local processProgressBar=createBar()richPrint(
'blue','bold','\u{1f528} Processing source code...')for place,data in config.
places do richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Generating processed project file...')local processedProject
=fileUtils.createProjectCopyWithPrefixedPaths(data.project,'processed-')fs.
writeFile('processed-'..data.project,serde.encode('json',processedProject))
local function processFiles(entryName)local processed,skipped=0,0 if fs.isFile(
entryName)then checkedFiles+=1 processProgressBar.setPercent(checkedFiles/
totalFiles)processProgressBar.setText('File '..checkedFiles..': '..(string.
match(entryName,'[^/\\]+$')or entryName)..'...')processProgressBar.render()if
string.find(entryName,'%.luau?$')then local subEntryProcessResult=process.spawn(
'darklua',{'process',entryName,'processed-'..entryName,'--format','retain-lines'
})if subEntryProcessResult.ok==true then processed+=1 else skipped+=1 fs.
writeFile('processed-'..entryName,fs.readFile(entryName))end else skipped+=1 fs.
writeFile('processed-'..entryName,fs.readFile(entryName))end elseif fs.isDir(
entryName)then fs.writeDir('processed-'..entryName)for _,subEntryName in fs.
readDir(entryName)do local subProcessed,subSkipped=processFiles(entryName..'/'..
subEntryName)processed+=subProcessed skipped+=subSkipped end end return
processed,skipped end for path in topLevelPaths do local pathProcessed,
pathSkipped=processFiles(path)totalProcessed+=pathProcessed totalSkipped+=
pathSkipped end end processProgressBar.clear()richPrint('blue','dim',
'Processed '..totalProcessed..' files, and left '..totalSkipped..' files as-is!'
)richPrint('blue','bold','\u{1f9fe}Removing story files...')local storyRemovals=
0 for path in topLevelPaths do storyRemovals+=fileUtils.removeFileMatches(
'processed-'..path,'[%._]story%.luau?$')end richPrint('blue','dim','Removed '..
storyRemovals..' story files!')richPrint('blue','bold',
'\u{1f9fe}Removing spec files...')local specRemovals=0 for path in topLevelPaths
do specRemovals+=fileUtils.removeFileMatches('processed-'..path,
'[%._]spec%.luau?$')end richPrint('blue','dim','Removed '..specRemovals..
' spec files!')for place,data in config.places do richPrint('blue','bold',
'\u{1f3d7}\u{fe0f}  Building place file...')local buildResult=process.spawn(
'rojo',{'build','processed-'..data.project,'--output',data.output})if
buildResult.ok==false then richPrint('red','bold','Build failure:')richPrint(
'red',buildResult.stderr)process.exit(1)return end buildFiles[place]=fs.
readFile(data.output)richPrint('blue','dim','Built project to `'..data.output..
'`!')fs.removeFile('processed-'..data.project)end for path in topLevelPaths do
fs.removeDir('processed-'..path)end else for place,data in config.places do
richPrint('blue','bold','\u{1f3d7}\u{fe0f}  Building place file...')local
buildResult=process.spawn('rojo',{'build',data.project,'--output',data.output})
if buildResult.ok==false then richPrint('red','bold','Build failure:')richPrint(
'red',buildResult.stderr)process.exit(1)return end table.insert(buildFiles,fs.
readFile(data.output))richPrint('blue','dim','Built project to `'..data.output..
'`!')end end stdio.write('\n')richPrint('green','bold',
"\u{1f3c1} We're nearly ready to publish!")stdio.write('\n')local envChoice=
stdio.prompt('select','Which environment would you like to publish to?',
enviromentOptions)local envTarget=enviromentOptions[envChoice]local
shutdownMessage=''stdio.write('\n')local shouldShutdown=stdio.prompt('confirm',
[[Would you like to soft-shutdown the servers after publishing?]])if
shouldShutdown then stdio.write('\n')shutdownMessage=stdio.prompt('text',
'What message should display during the server restart?',config.shutdown.
defaultMessage)end stdio.write('\n')richPrint('red','dim',
"\u{1f6c2} Let's double check before we publish!")richPrint('white','reset',
string.format('Source Commit: %s@%s',gitBranch,latestCommitHash)..string.format(
'\nEnvironment: %s',envTarget)..string.format('\nSoft Shutdown: %s',if
shouldShutdown then'Yes'else'No')..if shouldShutdown then string.format(
'\nShutdown Message: %s',shutdownMessage)else'')stdio.write('\n')local
doubleChecked=stdio.prompt('confirm','Is everything correct?')stdio.write('\n')
if not doubleChecked then richPrint('red','bold',
"\u{1f6d1} Publishing aborted, let's try again later.")process.exit(1)return end
richPrint('blue','bold','\u{1f680} Publishing to '..envTarget..'...')spinner.
setText('Deploying game...')spinner.start()local universeId,placeId for place,
data in config.places do local envConfig=data.enviroment[envTarget]universeId,
placeId=string.match(envConfig,'(%d+)/(%d+)')if universeId==nil or placeId==nil
then richPrint('red','bold',
"Could not parse IDs from environment configuration '"..envConfig.."'!")process.
exit(1)return end local publishSuccess,publishResponse=pcall(net.request,{url=
string.format(
[[https://apis.roblox.com/universes/v1/%s/places/%s/versions?versionType=Published]]
,universeId,placeId),method='POST',headers={['x-api-key']=config.auth.publishKey
,['Content-Type']='application/octet-stream'},body=buildFiles[place]})if
publishSuccess==false then richPrint('red','bold','Publish failure:')richPrint(
'red','reset',publishResponse)process.exit(1)return elseif publishResponse.ok==
false then richPrint('red','bold','Publish failure: '..publishResponse.
statusCode..' '..publishResponse.statusMessage)richPrint('red','reset',
publishResponse.body)process.exit(1)return end end spinner.stop()if
shouldShutdown then spinner.setText('Sending server shutdown message...')spinner
.start()local sanitizedMessage=string.gsub(shutdownMessage,'"','\\"')local
packet=string.gsub(config.shutdown.packetTemplate,'%$MESSAGE',sanitizedMessage)
local messageSuccess,messageResponse=pcall(net.request,{url=string.format(
[[https://apis.roblox.com/messaging-service/v1/universes/%s/topics/]]..config.
shutdown.topic,universeId),method='POST',headers={['x-api-key']=config.auth.
messageKey,['Content-Type']='application/json'},body=net.jsonEncode({['message']
=packet})})spinner.stop()if messageSuccess==false then richPrint('red','bold',
'Message failure:')richPrint('red','reset',messageResponse)process.exit(1)return
elseif messageResponse.ok==false then richPrint('red','bold',
'Message failure  : '..messageResponse.statusCode..' '..messageResponse.
statusMessage)richPrint('red','reset',messageResponse.body)process.exit(1)return
end richPrint('blue','dim',"Shutdown trigger has been sent with message '"..
shutdownMessage.."'!")end end}end,newEnv('LuneFlow/commands'))()end)newFile(
'LuneFlow/main',function()return setfenv(function()local stdio=require(
'@lune/stdio')local process=require('@lune/process')local outputUtils=require(
'utils/output-utils')local richPrint=outputUtils.richPrint local commands=
require('commands/init')local function main()table.sort(commands,function(a,b)
local commandA=commands[a]or{}local commandB=commands[b]or{}return(commandA.
priority or 0)<(commandB.priority or 0)end)local commandHandler local
commandOptions={}for index,commandData in commands do table.insert(
commandOptions,commandData.display)commandOptions[commandData.display]=
commandData if process.args[1]==commandData.command then commandHandler=
commandData break elseif index==#commands then local commandChoice=stdio.prompt(
'select','Which command would you like use?',commandOptions)local
commandDisplayed=commandOptions[commandChoice]commandHandler=commandOptions[
commandDisplayed]end end local success,msg=pcall(commandHandler.run)if not
success then richPrint('red','bold','\u{1f6a8} Error: '..tostring(msg))process.
exit(1)else richPrint('blue','bold',"\n\u{1f389} We're all done!")process.exit(0
)end return end local success,msg=pcall(main)if not success then richPrint('red'
,'bold','\u{1f6a8} Error: '..tostring(msg))process.exit(1)return else richPrint(
'blue','bold',"\n\u{1f389} We're all done!")process.exit(0)return end end,
newEnv('LuneFlow'))()end)newFile('LuneFlow/utils/file-utils',function()return
setfenv(function()local fs=require('@lune/fs')local serde=require('@lune/serde')
local process=require('@lune/process')local outputUtils=require('output-utils')
function ensureFileExists(path,failMsg)if not fs.isFile(path)then outputUtils.
richPrint('red','bold',failMsg or'\u{274c} File does not exist: '..path)process.
exit(1)return end end function countFiles(entryName)local files=0 if fs.isFile(
entryName)then files+=1 elseif fs.isDir(entryName)then for _,subEntryName in fs.
readDir(entryName)do files+=countFiles(entryName..'/'..subEntryName)end end
return files end function removeFileMatches(entryName,pattern)local removals=0
if fs.isFile(entryName)and string.find(entryName,pattern)then removals+=1 fs.
removeFile(entryName)elseif fs.isDir(entryName)then for _,subEntryName in fs.
readDir(entryName)do removals+=removeFileMatches(entryName..'/'..subEntryName,
pattern)end end return removals end function readPathsFromProject(projectPath)
local projectFile=fs.readFile(projectPath)local projectJson=serde.decode('json',
projectFile)local paths={}local function walkForPaths(project)if project['$path'
]then table.insert(paths,project['$path'])end for _,child in project do if type(
child)~='table'then continue end walkForPaths(child)end end walkForPaths(
projectJson)return paths end function createProjectCopyWithPrefixedPaths(
projectPath,prefix)local projectFile=fs.readFile(projectPath)local projectJson=
serde.decode('json',projectFile)local function walkForPaths(obj)if obj['$path']
then obj['$path']=prefix..obj['$path']end for _,child in obj do if type(child)~=
'table'then continue end walkForPaths(child)end end walkForPaths(projectJson)
return projectJson end return{ensureFileExists=ensureFileExists,countFiles=
countFiles,removeFileMatches=removeFileMatches,readPathsFromProject=
readPathsFromProject,createProjectCopyWithPrefixedPaths=
createProjectCopyWithPrefixedPaths}end,newEnv('LuneFlow/utils'))()end)newFile(
'LuneFlow/utils/output-utils',function()return setfenv(function()local stdio=
require('@lune/stdio')local task=require('@lune/task')local CLEAR_LINE=
'\27[2K\r'local FLUSH='\n\27[1A'local BAR_CHARS={' ','\u{258f}','\u{258e}',
'\u{258d}','\u{258c}','\u{258b}','\u{258a}','\u{2589}'}local SPINNER_FRAMES={
'\u{25dc}','\u{25dd}','\u{25de}','\u{25df}'}function richPrint(color,style,...)
stdio.write(stdio.color(color))stdio.write(stdio.style(style))stdio.write(...)
stdio.write('\n')stdio.write(stdio.color('reset'))stdio.write(stdio.style(
'reset'))end function createBar(percent,text)local bar={percent=math.clamp(
percent or 0,0,1),length=10,text=tostring(text or'')}function bar.setLength(
newLength)bar.length=math.clamp(newLength,2,100)end function bar.setPercent(
newPercent)bar.percent=math.clamp(newPercent,0,1)end function bar.setText(
newText)bar.text=tostring(newText)end function bar.render()local wholeWidth=math
.floor(bar.percent*bar.length)local remainderWidth=(bar.percent*bar.length)%1
local partWidth=math.floor(remainderWidth*8)local partChar=if wholeWidth>=bar.
length then''else BAR_CHARS[partWidth+1]local barText='['..string.rep('\u{2588}'
,wholeWidth)..partChar..string.rep(' ',bar.length-wholeWidth-1)..']'stdio.write(
CLEAR_LINE)stdio.write(stdio.style('dim'))stdio.write(stdio.color('green'))stdio
.write(barText)stdio.write(stdio.style('bold'))stdio.write(string.format(
' %.1f%% ',bar.percent*100))stdio.write(stdio.style('reset'))stdio.write(stdio.
color('reset'))stdio.write(bar.text or'')stdio.write(FLUSH)end function bar.
clear()stdio.write(CLEAR_LINE)stdio.write(FLUSH)bar.percent=0 bar.text=''end
return bar end function createSpinner()local spinner={animateThread=nil,text='',
frame=1}function spinner.setText(newText)spinner.text=tostring(newText)end
function spinner.start()if spinner.animateThread then return end spinner.
animateThread=task.spawn(function()while spinner.animateThread do stdio.write(
CLEAR_LINE)stdio.write(stdio.style('bold'))stdio.write(stdio.color('green'))
stdio.write(SPINNER_FRAMES[spinner.frame])stdio.write(stdio.style('reset'))stdio
.write(stdio.color('reset'))stdio.write(' '..spinner.text)stdio.write(FLUSH)
spinner.frame+=1 if spinner.frame>#SPINNER_FRAMES then spinner.frame=1 end task.
wait(1/20)end end)end function spinner.stop()if spinner.animateThread then task.
cancel(spinner.animateThread)spinner.animateThread=nil spinner.text=''spinner.
frame=1 stdio.write(CLEAR_LINE)stdio.write(FLUSH)end end return spinner end
return{richPrint=richPrint,createBar=createBar,createSpinner=createSpinner}end,
newEnv('LuneFlow/utils'))()end)newFile('LuneFlow/utils/remodel',function()return
setfenv(function()local fs=require('@lune/fs')local net=require('@lune/net')
local serde=require('@lune/serde')local process=require('@lune/process')local
roblox=require('@lune/roblox')do end do end local function
getAuthCookieWithFallbacks()local cookie=roblox.getAuthCookie()if cookie then
return cookie end local cookieFromEnv=process.env.REMODEL_AUTH if cookieFromEnv
and#cookieFromEnv>0 then return'.ROBLOSECURITY='..cookieFromEnv end for index,
arg in process.args do if arg=='--auth'then local cookieFromArgs=process.args[
index+1]if cookieFromArgs and#cookieFromArgs>0 then return'.ROBLOSECURITY='..
cookieFromArgs end break end end error(
'\t\tFailed to find ROBLOSECURITY cookie for authentication!\n\t\tMake sure you have logged into studio, or set the ROBLOSECURITY environment variable.\n\t'
)end local function downloadAssetId(assetId)local cookie=
getAuthCookieWithFallbacks()local assetApiResponse=net.request({url=
'https://assetdelivery.roblox.com/v2/assetId/'..assetId,headers={Accept=
'application/json',Cookie=cookie}})if not assetApiResponse.ok then error(string.
format([[Failed to fetch asset download link for asset id %s!
%s (%s)
%s]],
tostring(assetId),tostring(assetApiResponse.statusCode),tostring(
assetApiResponse.statusMessage),tostring(assetApiResponse.body)))end local
assetApiBody=serde.decode('json',assetApiResponse.body)if type(assetApiBody)~=
'table'then error(string.format(
'Asset delivery API returned an invalid response body!\n%s',assetApiResponse.
body))elseif type(assetApiBody.locations)~='table'then error(string.format(
'Asset delivery API returned an invalid response body!\n%s',assetApiResponse.
body))end local firstLocation=assetApiBody.locations[1]if type(firstLocation)~=
'table'then error(string.format(
'Asset delivery API returned no download locations!\n%s',assetApiResponse.body))
elseif type(firstLocation.location)~='string'then error(string.format(
'Asset delivery API returned no valid download locations!\n%s',assetApiResponse.
body))end local cdnResponse=net.request({url=firstLocation.location,headers={
Cookie=cookie}})if not cdnResponse.ok then error(string.format(
[[Failed to download asset with id %s from the Roblox cdn!
%s (%s)
%s]],
tostring(assetId),tostring(cdnResponse.statusCode),tostring(cdnResponse.
statusMessage),tostring(cdnResponse.body)))end return cdnResponse.body end
local function uploadAssetId(assetId,contents)local cookie=
getAuthCookieWithFallbacks()local headers={['User-Agent']='Roblox/WinInet',[
'Content-Type']='application/octet-stream',Accept='application/json',Cookie=
cookie}local uploadResponse=net.request({url=
'https://data.roblox.com/Data/Upload.ashx?assetid='..assetId,body=contents,
method='POST',headers=headers})if not uploadResponse.ok and uploadResponse.
statusCode==403 and uploadResponse.headers['x-csrf-token']~=nil then headers[
'X-CSRF-Token']=uploadResponse.headers['x-csrf-token']uploadResponse=net.
request({url='https://data.roblox.com/Data/Upload.ashx?assetid='..assetId,body=
contents,method='POST',headers=headers})end if not uploadResponse.ok then error(
string.format('Failed to upload asset with id %s to Roblox!\n%s (%s)\n%s',
tostring(assetId),tostring(uploadResponse.statusCode),tostring(uploadResponse.
statusMessage),tostring(uploadResponse.body)))end end local remodel={}function
remodel.readPlaceFile(filePath)local placeFile=fs.readFile(filePath)local place=
roblox.deserializePlace(placeFile)return place end function remodel.
readModelFile(filePath)local modelFile=fs.readFile(filePath)local model=roblox.
deserializeModel(modelFile)return model end function remodel.readPlaceAsset(
assetId)local contents=downloadAssetId(assetId)local place=roblox.
deserializePlace(contents)return place end function remodel.readModelAsset(
assetId)local contents=downloadAssetId(assetId)local place=roblox.
deserializeModel(contents)return place end function remodel.writePlaceFile(
filePath,dataModel)local asBinary=string.sub(filePath,-6)=='.rbxl'local asXml=
string.sub(filePath,-6)=='.rbxlx'assert(asBinary or asXml,
'File path must have .rbxl or .rbxlx extension')local placeFile=roblox.
serializePlace(dataModel,asXml)fs.writeFile(filePath,placeFile)end function
remodel.writeModelFile(filePath,instance)local asBinary=string.sub(filePath,-6)
=='.rbxm'local asXml=string.sub(filePath,-6)=='.rbxmx'assert(asBinary or asXml,
'File path must have .rbxm or .rbxmx extension')local placeFile=roblox.
serializeModel({instance},asXml)fs.writeFile(filePath,placeFile)end function
remodel.writeExistingPlaceAsset(dataModel,assetId)local placeFile=roblox.
serializePlace(dataModel)uploadAssetId(assetId,placeFile)end function remodel.
writeExistingModelAsset(instance,assetId)local modelFile=roblox.serializeModel({
instance})uploadAssetId(assetId,modelFile)end remodel.readFile=fs.readFile
remodel.readDir=fs.readDir remodel.writeFile=fs.writeFile remodel.createDirAll=
fs.writeDir remodel.removeFile=fs.removeFile remodel.removeDir=fs.removeDir
remodel.isFile=fs.isFile remodel.isDir=fs.isDir return remodel end,newEnv(
'LuneFlow/utils'))()end)newFile('LuneFlow/utils/schemas/assets',function()return
setfenv(function()local t=require('../t')return t.interface({assets=t.array(t.
interface({id=t.number,type=t.string,targets=t.optional(t.array(t.string)),
output=t.string}))})end,newEnv('LuneFlow/utils/schemas'))()end)newFile(
'LuneFlow/utils/schemas/config',function()return setfenv(function()local t=
require('../t')return t.interface({shutdown=t.interface({topic=t.string,
defaultMessage=t.string,packetTemplate=t.string}),tests=t.interface({runner=t.
string,project=t.string,output=t.string}),places=t.map(t.string,t.interface({
project=t.string,output=t.string,environments=t.interface({Testing=t.string,
Staging=t.string,Production=t.string})}))})end,newEnv('LuneFlow/utils/schemas')
)()end)newFile('LuneFlow/utils/t',function()return setfenv(function()local t={}
function t.type(typeName)return function(value)local valueType=type(value)if
valueType==typeName then return true else return false,string.format(
'%s expected, got %s',typeName,valueType)end end end function t.typeof(typeName)
return function(value)local valueType=typeof(value)if valueType==typeName then
return true else return false,string.format('%s expected, got %s',typeName,
valueType)end end end function t.any(value)if value~=nil then return true else
return false,'any expected, got nil'end end t.boolean=t.typeof('boolean')t.
thread=t.typeof('thread')t.callback=t.typeof('function')t['function']=t.callback
t.none=t.typeof('nil')t['nil']=t.none t.string=t.typeof('string')t.table=t.
typeof('table')t.userdata=t.type('userdata')function t.number(value)local
valueType=typeof(value)if valueType=='number'then if value==value then return
true else return false,'unexpected NaN value'end else return false,string.
format('number expected, got %s',valueType)end end function t.nan(value)local
valueType=typeof(value)if valueType=='number'then if value~=value then return
true else return false,'unexpected non-NaN value'end else return false,string.
format('number expected, got %s',valueType)end end t.Axes=t.typeof('Axes')t.
BrickColor=t.typeof('BrickColor')t.CatalogSearchParams=t.typeof(
'CatalogSearchParams')t.CFrame=t.typeof('CFrame')t.Color3=t.typeof('Color3')t.
ColorSequence=t.typeof('ColorSequence')t.ColorSequenceKeypoint=t.typeof(
'ColorSequenceKeypoint')t.DateTime=t.typeof('DateTime')t.DockWidgetPluginGuiInfo
=t.typeof('DockWidgetPluginGuiInfo')t.Enum=t.typeof('Enum')t.EnumItem=t.typeof(
'EnumItem')t.Enums=t.typeof('Enums')t.Faces=t.typeof('Faces')t.FloatCurveKey=t.
typeof('FloatCurveKey')t.Font=t.typeof('Font')t.Instance=t.typeof('Instance')t.
NumberRange=t.typeof('NumberRange')t.NumberSequence=t.typeof('NumberSequence')t.
NumberSequenceKeypoint=t.typeof('NumberSequenceKeypoint')t.OverlapParams=t.
typeof('OverlapParams')t.PathWaypoint=t.typeof('PathWaypoint')t.
PhysicalProperties=t.typeof('PhysicalProperties')t.Random=t.typeof('Random')t.
Ray=t.typeof('Ray')t.RaycastParams=t.typeof('RaycastParams')t.RaycastResult=t.
typeof('RaycastResult')t.RBXScriptConnection=t.typeof('RBXScriptConnection')t.
RBXScriptSignal=t.typeof('RBXScriptSignal')t.Rect=t.typeof('Rect')t.Region3=t.
typeof('Region3')t.Region3int16=t.typeof('Region3int16')t.TweenInfo=t.typeof(
'TweenInfo')t.UDim=t.typeof('UDim')t.UDim2=t.typeof('UDim2')t.Vector2=t.typeof(
'Vector2')t.Vector2int16=t.typeof('Vector2int16')t.Vector3=t.typeof('Vector3')t.
Vector3int16=t.typeof('Vector3int16')function t.literal(...)local size=select(
'#',...)if size==1 then local literal=...return function(value)if value~=literal
then return false,string.format('expected %s, got %s',tostring(literal),
tostring(value))end return true end else local literals={}for i=1,size do local
value=select(i,...)literals[i]=t.literal(value)end return t.union(table.unpack(
literals,1,size))end end t.exactly=t.literal function t.keyOf(keyTable)local
keys={}local length=0 for key in pairs(keyTable)do length=length+1 keys[length]=
key end return t.literal(table.unpack(keys,1,length))end function t.valueOf(
valueTable)local values={}local length=0 for _,value in pairs(valueTable)do
length=length+1 values[length]=value end return t.literal(table.unpack(values,1,
length))end function t.integer(value)local success,errMsg=t.number(value)if not
success then return false,errMsg or''end if value%1==0 then return true else
return false,string.format('integer expected, got %s',value)end end function t.
numberMin(min)return function(value)local success,errMsg=t.number(value)if not
success then return false,errMsg or''end if value>=min then return true else
return false,string.format('number >= %s expected, got %s',min,value)end end end
function t.numberMax(max)return function(value)local success,errMsg=t.number(
value)if not success then return false,errMsg end if value<=max then return true
else return false,string.format('number <= %s expected, got %s',max,value)end
end end function t.numberMinExclusive(min)return function(value)local success,
errMsg=t.number(value)if not success then return false,errMsg or''end if min<
value then return true else return false,string.format(
'number > %s expected, got %s',min,value)end end end function t.
numberMaxExclusive(max)return function(value)local success,errMsg=t.number(value
)if not success then return false,errMsg or''end if value<max then return true
else return false,string.format('number < %s expected, got %s',max,value)end end
end t.numberPositive=t.numberMinExclusive(0)t.numberNegative=t.
numberMaxExclusive(0)function t.numberConstrained(min,max)assert(t.number(min))
assert(t.number(max))local minCheck=t.numberMin(min)local maxCheck=t.numberMax(
max)return function(value)local minSuccess,minErrMsg=minCheck(value)if not
minSuccess then return false,minErrMsg or''end local maxSuccess,maxErrMsg=
maxCheck(value)if not maxSuccess then return false,maxErrMsg or''end return true
end end function t.numberConstrainedExclusive(min,max)assert(t.number(min))
assert(t.number(max))local minCheck=t.numberMinExclusive(min)local maxCheck=t.
numberMaxExclusive(max)return function(value)local minSuccess,minErrMsg=
minCheck(value)if not minSuccess then return false,minErrMsg or''end local
maxSuccess,maxErrMsg=maxCheck(value)if not maxSuccess then return false,
maxErrMsg or''end return true end end function t.match(pattern)assert(t.string(
pattern))return function(value)local stringSuccess,stringErrMsg=t.string(value)
if not stringSuccess then return false,stringErrMsg end if string.match(value,
pattern)==nil then return false,string.format('%q failed to match pattern %q',
value,pattern)end return true end end function t.optional(check)assert(t.
callback(check))return function(value)if value==nil then return true end local
success,errMsg=check(value)if success then return true else return false,string.
format('(optional) %s',errMsg or'')end end end function t.tuple(...)local checks
={...}return function(...)local args={...}for i,check in ipairs(checks)do local
success,errMsg=check(args[i])if success==false then return false,string.format(
'Bad tuple index #%s:\n\t%s',i,errMsg or'')end end return true end end function
t.keys(check)assert(t.callback(check))return function(value)local tableSuccess,
tableErrMsg=t.table(value)if tableSuccess==false then return false,tableErrMsg
or''end for key in pairs(value)do local success,errMsg=check(key)if success==
false then return false,string.format('bad key %s:\n\t%s',tostring(key),errMsg
or'')end end return true end end function t.values(check)assert(t.callback(check
))return function(value)local tableSuccess,tableErrMsg=t.table(value)if
tableSuccess==false then return false,tableErrMsg or''end for key,val in pairs(
value)do local success,errMsg=check(val)if success==false then return false,
string.format('bad value for key %s:\n\t%s',tostring(key),errMsg or'')end end
return true end end function t.map(keyCheck,valueCheck)assert(t.callback(
keyCheck))assert(t.callback(valueCheck))local keyChecker=t.keys(keyCheck)local
valueChecker=t.values(valueCheck)return function(value)local keySuccess,keyErr=
keyChecker(value)if not keySuccess then return false,keyErr or''end local
valueSuccess,valueErr=valueChecker(value)if not valueSuccess then return false,
valueErr or''end return true end end function t.set(valueCheck)return t.map(
valueCheck,t.literal(true))end do local arrayKeysCheck=t.keys(t.integer)function
t.array(check)assert(t.callback(check))local valuesCheck=t.values(check)return
function(value)local keySuccess,keyErrMsg=arrayKeysCheck(value)if keySuccess==
false then return false,string.format('[array] %s',keyErrMsg or'')end local
arraySize=0 for _ in ipairs(value)do arraySize=arraySize+1 end for key in pairs(
value)do if key<1 or key>arraySize then return false,string.format(
'[array] key %s must be sequential',tostring(key))end end local valueSuccess,
valueErrMsg=valuesCheck(value)if not valueSuccess then return false,string.
format('[array] %s',valueErrMsg or'')end return true end end function t.
strictArray(...)local valueTypes={...}assert(t.array(t.callback)(valueTypes))
return function(value)local keySuccess,keyErrMsg=arrayKeysCheck(value)if
keySuccess==false then return false,string.format('[strictArray] %s',keyErrMsg
or'')end if#valueTypes<#value then return false,string.format(
'[strictArray] Array size exceeds limit of %d',#valueTypes)end for idx,typeFn in
pairs(valueTypes)do local typeSuccess,typeErrMsg=typeFn(value[idx])if not
typeSuccess then return false,string.format('[strictArray] Array index #%d - %s'
,idx,typeErrMsg)end end return true end end end do local callbackArray=t.array(t
.callback)function t.union(...)local checks={...}assert(callbackArray(checks))
return function(value)for _,check in ipairs(checks)do if check(value)then return
true end end return false,'bad type for union'end end t.some=t.union function t.
intersection(...)local checks={...}assert(callbackArray(checks))return function(
value)for _,check in ipairs(checks)do local success,errMsg=check(value)if not
success then return false,errMsg or''end end return true end end t.every=t.
intersection end do local checkInterface=t.map(t.any,t.callback)function t.
interface(checkTable)assert(checkInterface(checkTable))return function(value)
local tableSuccess,tableErrMsg=t.table(value)if tableSuccess==false then return
false,tableErrMsg or''end for key,check in pairs(checkTable)do local success,
errMsg=check(value[key])if success==false then return false,string.format(
'[interface] bad value for %s:\n\t%s',tostring(key),errMsg or'')end end return
true end end function t.strictInterface(checkTable)assert(checkInterface(
checkTable))return function(value)local tableSuccess,tableErrMsg=t.table(value)
if tableSuccess==false then return false,tableErrMsg or''end for key,check in
pairs(checkTable)do local success,errMsg=check(value[key])if success==false then
return false,string.format('[interface] bad value for %s:\n\t%s',tostring(key),
errMsg or'')end end for key in pairs(value)do if not checkTable[key]then return
false,string.format('[interface] unexpected field %q',tostring(key))end end
return true end end end function t.instanceOf(className,childTable)assert(t.
string(className))local childrenCheck if childTable~=nil then childrenCheck=t.
children(childTable)end return function(value)local instanceSuccess,
instanceErrMsg=t.Instance(value)if not instanceSuccess then return false,
instanceErrMsg or''end if value.ClassName~=className then return false,string.
format('%s expected, got %s',className,value.ClassName)end if childrenCheck then
local childrenSuccess,childrenErrMsg=childrenCheck(value)if not childrenSuccess
then return false,childrenErrMsg end end return true end end t.instance=t.
instanceOf function t.instanceIsA(className,childTable)assert(t.string(className
))local childrenCheck if childTable~=nil then childrenCheck=t.children(
childTable)end return function(value)local instanceSuccess,instanceErrMsg=t.
Instance(value)if not instanceSuccess then return false,instanceErrMsg or''end
if not value:IsA(className)then return false,string.format('%s expected, got %s'
,className,value.ClassName)end if childrenCheck then local childrenSuccess,
childrenErrMsg=childrenCheck(value)if not childrenSuccess then return false,
childrenErrMsg end end return true end end function t.enum(enum)assert(t.Enum(
enum))return function(value)local enumItemSuccess,enumItemErrMsg=t.EnumItem(
value)if not enumItemSuccess then return false,enumItemErrMsg end if value.
EnumType==enum then return true else return false,string.format(
'enum of %s expected, got enum of %s',tostring(enum),tostring(value.EnumType))
end end end do local checkWrap=t.tuple(t.callback,t.callback)function t.wrap(
callback,checkArgs)assert(checkWrap(callback,checkArgs))return function(...)
assert(checkArgs(...))return callback(...)end end end function t.strict(check)
return function(...)assert(check(...))end end do local checkChildren=t.map(t.
string,t.callback)function t.children(checkTable)assert(checkChildren(checkTable
))return function(value)local instanceSuccess,instanceErrMsg=t.Instance(value)if
not instanceSuccess then return false,instanceErrMsg or''end local
childrenByName={}for _,child in ipairs(value:GetChildren())do local name=child.
Name if checkTable[name]then if childrenByName[name]then return false,string.
format('Cannot process multiple children with the same name %q',name)end
childrenByName[name]=child end end for name,check in pairs(checkTable)do local
success,errMsg=check(childrenByName[name])if not success then return false,
string.format('[%s.%s] %s',value:GetFullName(),name,errMsg or'')end end return
true end end end return t end,newEnv('LuneFlow/utils'))()end)newFile(
'LuneFlow/utils/validate-utils',function()return setfenv(function()local process
=require('@lune/process')local configSchema=require('schemas/config')local
assetSchema=require('schemas/assets')local richPrint=require('output-utils').
richPrint local function validateConfig(config)assert(configSchema(config))if
string.find(config.shutdown.packetTemplate,'%$MESSAGE')==nil then richPrint(
'red','bold','Invalid project.config.toml file.')richPrint('red','bold',
[[Please ensure that shutdown.packetTemplate contains $MESSAGE where you want the message to be injected, like so:
packetTemplate: '{"Message":"$MESSAGE", "Type":"Shutdown"}']]
)process.exit(1)return end for placeName,placeData in config.places do for
envName,envId in placeData.environments do if type(envName)~='string'or type(
envId)~='string'or string.find(envId,'/')==nil or string.match(envId,'[^%d/]')~=
nil then richPrint('red','bold','Invalid project.config.toml file.')richPrint(
'red','bold',"Your environments contain an invalid id, '"..tostring(envName)..
' = '..tostring(envId).."'."..
[[

Please ensure it contains a valid environments table like so:
]]..
[[[places.default]
project = "default.project.json"
output = "out/default.rbxl"

[places.default.environments]
Testing = "universeId/placeId"
Staging = "universeId/placeId"
Production = "universeId/placeId"]]
)process.exit(1)return end end end end local function validateAssets(config)
assert(assetSchema(config))for _,assetData in config.assets do if assetData.type
~='Place'and assetData.type~='Asset'then richPrint('red','bold',
'Invalid assets.config.toml file.')richPrint('red','bold',string.format(
[[Invalid asset of type %q. Ensure that your asset type is either "Place" or "Asset"]]
,assetData))process.exit(1)return end end end local function validateTestsConfig
(config)if type(config.tests)~='table'or type(config.tests.project)~='string'or
type(config.tests.output)~='string'or type(config.tests.runner)~='string'then
richPrint('red','bold',
[[The project.config.toml file does not have a valid test set up.]])richPrint(
'red','bold',
[[Please ensure it contains a valid tests table like so:
[tests]
project = "tests.project.json"
output = "tests.rbxl"
runner = "tests/runner.lua"]]
)process.exit(1)return end end local function validateGitStatus(gitStatus,
projectPaths,extraPaths)local relevantPaths=table.create(#projectPaths+#
extraPaths)table.move(projectPaths,1,#projectPaths,1,relevantPaths)table.move(
extraPaths,1,#extraPaths,#projectPaths+1,relevantPaths)local shouldAbort=false
for _,status in gitStatus do if string.find(status,'%S')==nil then continue end
local state,file=string.match(status,'(%S+)%s+(.+)$')if state==nil or file==nil
then richPrint('red','bold','Failed to parse git status line: '..status)process.
exit(1)return end local stateText=if string.find(state,'M')then
' has uncommitted changes'elseif string.find(state,'D')then
' has an uncommitted removal'elseif string.find(state,'R')then
' has an uncommitted rename'else' has not been committed'if string.find(file,
'%.luau?$')or string.find(file,'%.rbxmx?$')or string.find(file,'%.json5?$')or
string.find(file,'%.txt$')or string.find(file,'%.toml$')then for _,path in
relevantPaths do if string.find(file,'^'..path)then richPrint('red','bold',file
..stateText)shouldAbort=true break end end end end if shouldAbort then
richPrint('red','bold','Please commit your changes before continuing.')process.
exit(1)return end end local function filterThirdPartyPaths(paths)local filtered=
table.create(#paths)for _,path in paths do if string.find(path,'[Pp]ackages')or
string.find(path,'[Vv]endor')then continue end table.insert(filtered,path)end
return filtered end return{validateConfig=validateConfig,validateAssets=
validateAssets,validateTestsConfig=validateTestsConfig,validateGitStatus=
validateGitStatus,filterThirdPartyPaths=filterThirdPartyPaths}end,newEnv(
'LuneFlow/utils'))()end)init()