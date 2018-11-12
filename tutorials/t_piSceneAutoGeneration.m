%% Automatically generate an automotive scene
%
%    t_piSceneAutoGeneration
%
% Description:
%   Illustrates the use of ISETCloud, ISET3d, ISETCam and Flywheel to
%   generate driving scenes.  This example works with the PBRT-V3
%   docker container (not V2).
%
% Author: ZL
%
% See also
%   piSceneAuto, piSkymapAdd, gCloud, SUMO

%{ 
% Example - let's make a small example to run, if possible.  Say two
cars, no buildings.  If we can make it run in 10 minutes,
that would be good.
%
%}

%% Initialize ISET and Docker
ieInit;
if ~piDockerExists, piDockerConfig; end
if ~mcGcloudExists, mcGcloudConfig; end

%% Open the Flywheel site
st = scitran('stanfordlabs');

%% Initialize your GCP cluster

% The Google cloud platform (gcp) includes a large number of
% parameters that define the cluster. We also use the gcp object to
% store certain parameters about the rendering.

tic
% gcp = gCloud('configuration','gcp-pbrtv3-central-32');
gcp = gCloud('configuration','cloudRendering-pbrtv3-central-standard-32cpu-120m-flywheel');
% gcp = gCloud('configuration','gcp-pbrtv3-central-64cpu-120m');
% gcp-pbrtv3-central-high-64cpu-flywheel
% gcp-pbrtv3-central-32cpu-120m-flywheel
% gcp = gCloud('configuration','gcp-pbrtv3-central-32cpu-208m-flywheel');
% gcp = gCloud('configuration','gcp-pbrtv3-central-64cpu-120m');
% gcp = gCloud('configuration','gcp-pbrtv3-central-32');

toc
gcp.renderDepth = 1;  % Create the depth map
gcp.renderMesh  = 1;  % Create the object mesh for subsequent use
gcp.targets =[];      % clear job list

% Print out the gcp parameters for the user
str = gcp.configList;

%% Helpful for debugging
% clearvars -except gcp st thisR_scene

%%  Example scene creation
%
% This is where we pull down the assets from Flywheel and assemble
% them into an asset list.  That is managed in piSceneAuto

tic
sceneType = 'city3';
% roadType = 'cross';
% sceneType = 'highway';
<<<<<<< HEAD
roadType = 'cross';
=======

roadType = 'curve_6lanes_001';
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
% roadType = 'highway_straight_4lanes_001';

trafficflowDensity = 'medium';

dayTime = 'noon';
<<<<<<< HEAD
% Choose a timestamp(1~360)  
timestamp = 95;
% Normally we want only one scene per generation. 
=======

% Choose a timestamp(1~360), which is the moment in the SUMO
% simulation that we record the data.  This could be fixed or random,
% and since SUMO runs
timestamp = 100;

% Normally we want only one scene per generation.
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
nScene = 1;
% Choose whether we want to enable cloudrender
cloudRender = 1;
% Return an array of render recipe according to given number of scenes.
% takes about 150 seconds
[thisR_scene,road] = piSceneAuto('sceneType',sceneType,...
    'roadType',roadType,...
    'trafficflowDensity',trafficflowDensity,...
    'dayTime',dayTime,...
    'timeStamp',timestamp,...
    'nScene',nScene,...
    'cloudRender',cloudRender,...
    'scitran',st);
toc

%% Add a skymap and add SkymapFwInfor to fwList

% fwList contains information about objects in Flywheel that you will
% use to render this scene.  It is a long string of the container IDS
% and file names.
%
dayTime = 'noon';
[thisR_scene,skymapfwInfo] = piSkymapAdd(thisR_scene,dayTime);
road.fwList = [road.fwList,' ',skymapfwInfo];

<<<<<<< HEAD
%%
%% Bundle the camera to a ramdom selected car from trafficflow
% load in trafficflow
=======
%% Add a camera to one of the cars

% To place the camera, we find a car and place a camera at the front
% of the car.  We find the car using the trafficflow information.
%
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
load(fullfile(piRootPath,'local','trafficflow',sprintf('%s_%s_trafficflow.mat',road.name,trafficflowDensity)),'trafficflow');
% from = thisR_scene.assets(3).position;

thisTrafficflow = trafficflow(timestamp);
<<<<<<< HEAD
nextTrafficflow = trafficflow(timestamp+1);
CamOrientation  = 270;
[thisCar,from,to,ori] = piCamPlace('thisTrafficflow',thisTrafficflow,...
                           'CamOrientation',CamOrientation);
thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up   = [0;1;0];
% Add motion info
thisR_road  = piMotionBlurEgo(thisR_scene,...
                              'fps',30,...
                              'nextTrafficflow',nextTrafficflow,...
                              'thisCar',thisCar);

%% Render parameter
=======
CamOrientation =100;
[from,to,ori] = piCamPlace('trafficflow',thisTrafficflow,...
    'CamOrientation',CamOrientation);

thisR_scene.lookAt.from = from;
thisR_scene.lookAt.to   = to;
thisR_scene.lookAt.up = [0;1;0];
thisR_scene.lookAt.from

%% Render parameters
% This could be set by default, e.g.,

% Could look like this
%  autoRender = piAutoRenderParameters;
%  autoRender.x = y;
%
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
% Default is a relatively low samples/pixel (256).

% thisR_scene.set('camera','realistic');
% thisR_scene.set('lensfile',fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat'));
xRes = 1280;
yRes = 720;
pSamples = 256;
thisR_scene.set('film resolution',[xRes yRes]);
thisR_scene.set('pixel samples',pSamples);
thisR_scene.set('fov',45);
thisR_scene.film.diagonal.value=10;
thisR_scene.film.diagonal.type = 'float';
thisR_scene.integrator.maxdepth.value = 10;
thisR_scene.integrator.subtype = 'bdpt';
thisR_scene.sampler.subtype = 'sobol';
<<<<<<< HEAD
% thisR_scene.integrator.lightsamplestrategy.type = 'string';
% thisR_scene.integrator.lightsamplestrategy.value = 'spatial';
% Write out the scene
=======
thisR_scene.integrator.lightsamplestrategy.type = 'string';
thisR_scene.integrator.lightsamplestrategy.value = 'spatial';

%% Write out the scene into a PBRT file

>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
if contains(sceneType,'city')
    outputDir = fullfile(piRootPath,'local',strrep(road.roadinfo.name,'city',sceneType));
    thisR_scene.inputFile = fullfile(outputDir,[strrep(road.roadinfo.name,'city',sceneType),'.pbrt']);
else
    outputDir = fullfile(piRootPath,'local',strcat(sceneType,'_',road.name));
    thisR_scene.inputFile = fullfile(outputDir,[strcat(sceneType,'_',road.name),'.pbrt']);
end

% We might use md5 to has the parameters and put them in the file
% name.
if ~exist(outputDir,'dir'), mkdir(outputDir); end
<<<<<<< HEAD
filename = sprintf('%s_sp%d_%s_%s_ts%d_from_%0.2f_%0.2f_%0.2f_ori_%0.2f_%i_%i_%i_%i_%i_%0.0f.pbrt',sceneType,pSamples,roadType,dayTime,timestamp,thisR_scene.lookAt.from,ori,clock);
sceneInfo.sceneType = sceneType;
sceneInfo.resolution = [xRes yRes];
sceneInfo.pSamples  = pSamples;
sceneInfo.roadType  = roadType;
sceneInfo.dayTime   = dayTime;
sceneInfo.timestamp = timestamp;
sceneInfo.lookAt    = thisR_scene.lookAt;
sceneInfo.ori       = ori;
=======
filename = sprintf('%s_sp%d_%s_%s_ts%d_from_%0.2f_%0.2f_%0.2f_ori_%0.2f_%i_%i_%i_%i_%i_%0.0f.pbrt',...
    sceneType,pSamples,roadType,dayTime,timestamp,thisR_scene.lookAt.from,ori,clock);
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
outputFile = fullfile(outputDir,filename);
thisR_scene.set('outputFile',outputFile);

% Do the writing
piWrite(thisR_scene,'creatematerials',true,...
    'overwriteresources',false,'lightsFlag',false,...
    'thistrafficflow',thisTrafficflow);

% Upload the information to Flywheel.
gcp.fwUploadPBRT(thisR_scene,'scitran',st,'road',road);

<<<<<<< HEAD
%
addPBRTTarget(gcp,thisR_scene,sceneInfo);
=======
% Tell the gcp object about this target scene
addPBRTTarget(gcp,thisR_scene);
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
fprintf('Added one target.  Now %d current targets\n',length(gcp.targets));

%% Describe the target to the user

gcp.targetsList;

%% This invokes the PBRT-V3 docker image

gcp.render();

%% Monitor the processes on GCP

[podnames,result] = gcp.Podslist('print',false);
nPODS = length(result.items);
cnt = 0;
time = 0;
while cnt < length(nPODS)
    cnt = podSucceeded(gcp);
    pause(60);
    time = time+1;
    fprintf('******Elapsed Time: %d mins****** \n',time);
end

%{
%  You can get a lot of information about the job this way
podname = gcp.Podslist
gcp.PodDescribe(podname{1})
 gcp.Podlog(podname{1});
%}

% Keep checking for the data, every 15 sec, and download it is there

%% Download files from Flywheel

[scene,scene_mesh,label]   = gcp.fwDownloadPBRT('scitran',st);
disp('Data downloaded');

<<<<<<< HEAD
%% Show it in ISET
=======
%% Show the rendered image using ISETCam
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35

% Some of the images have rendering artifiacts.  These are partially
% removed using piWhitepixelRemove
%
for ii =1:length(scene)
    scene_oi{ii} = piWhitepixelsRemove(scene{ii});
    xCrop = oiGet(scene_oi{ii},'cols')-xRes;
    yCrop = oiGet(scene_oi{ii},'rows')-yRes;
    scene_crop{ii} = oiCrop(scene_oi{ii},[xCrop/2 yCrop/2 xRes-1 yRes-1]);
    %     scene_crop{ii}.depthMap = imcrop(scene_crop{ii}.depthMap,[xCrop/2 yCrop/2 xRes-1 yRes-1]);
    ieAddObject(scene_crop{ii});
    oiSet(scene_crop{ii},'gamma',0.85);
    pngFigure = oiGet(scene_crop{ii},'rgb image');
    
    % Get the class labels, depth map, bounding boxes for ground
    % truth. This usually takes about 15 secs
    tic
    scene_label{ii} = piSceneAnnotation(scene_mesh{ii},label{ii},st);toc
    [sceneFolder,sceneName]=fileparts(label{ii});
    sceneName = strrep(sceneName,'_mesh','');
    irradiancefile = fullfile(sceneFolder,[sceneName,'_ir.png']);
    imwrite(pngFigure,irradiancefile); % Save this scene file
    
    %% Visualization of the ground truth bounding boxes
    vcNewGraphWin;
    imshow(pngFigure);
    fds = fieldnames(scene_label{ii}.bbox2d);
<<<<<<< HEAD
    for kk = 5
    detections = scene_label{ii}.bbox2d.(fds{kk});
    r = rand; g = rand; b = rand;    
    if r< 0.2 && g < 0.2 && b< 0.2
        r = 0.5; g = rand; b = rand;
    end
    for jj=1:length(detections)
        pos = [detections{jj}.bbox2d.xmin detections{jj}.bbox2d.ymin ...
            detections{jj}.bbox2d.xmax-detections{jj}.bbox2d.xmin ...
            detections{jj}.bbox2d.ymax-detections{jj}.bbox2d.ymin];
        
        rectangle('Position',pos,'EdgeColor',[r g b],'LineWidth',2);
        t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,num2str(jj));
       %t=text(detections{jj}.bbox2d.xmin+2.5,detections{jj}.bbox2d.ymin-8,fds{kk});
        t.Color = [0 0 0];
        t.BackgroundColor = [r g b];
        t.FontSize = 15;
    end
=======
    for kk = 3
        detections = scene_label{ii}.bbox2d.(fds{kk});
        r = rand;
        g = rand;
        b = rand;
        for jj=1:length(detections)
            pos = [detections{jj}.bbox2d.xmin detections{jj}.bbox2d.ymin ...
                detections{jj}.bbox2d.xmax-detections{jj}.bbox2d.xmin ...
                detections{jj}.bbox2d.ymax-detections{jj}.bbox2d.ymin];
            
            rectangle('Position',pos,'EdgeColor',[r g b]);
        end
>>>>>>> 4349713c169e324aee8340eefe7644b9138f0e35
    end
    drawnow;
    
end
oiWindow;
truesize;

%% Remove all jobs.
% Anything still running is a stray that never completed.  We should
% say more.

% gcp.JobsRmAll();

%% END

%% Change the camera lens
%{
% TODO: We need to put the following into piCameraCreate, but how do we
% differentiate between a version 2 vs a version 3 camera? The
% thisR.version can tell us, but piCameraCreate does not take a thisR as
% input. For now let's put things in manually.

thisR.camera = struct('type','Camera','subtype','realistic');

% PBRTv3 will throw an error if there is the extra focal length on the top
% of the lens file, so our lens files have to be slightly modified.
lensFile = fullfile(piRootPath,'data','lens','wide.56deg.6.0mm_v3.dat');
thisR.camera.lensfile.value = lensFile;
% exist(lensFile,'file')

% Attach the lens
thisR.camera.lensfile.value = lensFile; % mm
thisR.camera.lensfile.type = 'string';

% Set the aperture to be the largest possible.
thisR.camera.aperturediameter.value = 1; % mm
thisR.camera.aperturediameter.type = 'float';

% Focus at roughly meter away.
thisR.camera.focusdistance.value = 1; % meter
thisR.camera.focusdistance.type = 'float';

% Use a 1" sensor size
thisR.film.diagonal.value = 16;
thisR.film.diagonal.type = 'float';
%}