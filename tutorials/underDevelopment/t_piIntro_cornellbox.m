%% Render a Cornell box
%
% Status:   Error on line 37.  Adding the light has a problem with the
% translate parameter.  Error at the end with the iLightDelete().
%
% piLightDelete is a problem on line 53.
%
% Zhenyi, SCIEN

%%
ieInit;
if ~piDockerExists, piDockerConfig; end

%% Read a Cornell box pbrt file

sceneName = 'cornell_box';
filename = fullfile(piRootPath, 'data', 'V3', sceneName, [sceneName, '.pbrt']);
thisR = piRead(filename);

%% Summarize the recipe

thisR.summarize;

%% Add an area light at predefined region

% Default light spectrum is D65
thisR = piLightAdd(thisR, 'type', 'area', 'lightspectrum', 'Tungsten');

%%  Rendering parameters

filmRes = thisR.get('film resolution');
thisR.set('fov',[30 30]); % by default, the fov is setted as horizontal and vertical
% thisR.set('film resolution',filmRes);
thisR.set('pixel samples',8);
thisR.set('nbounces',5);
thisR.integrator.subtype ='directlighting'; 

%% Write and render

piWrite(thisR, 'creatematerials', true);
scene = piRender(thisR, 'rendertype', 'radiance');
sceneWindow(scene);
% thisR.set('fov',[30 20]);

%% Add another point light

thisR = piLightAdd(thisR, 'type', 'point', 'from',[-0.25,-0.25,1.68]);
piWrite(thisR, 'creatematerials', true);
[scene, result] = piRender(thisR, 'rendertype', 'radiance');
sceneWindow(scene);
sceneSet(scene,'gamma',0.3);

%% Change light to D65

lightsource = piLightGet(thisR);
piLightDelete(thisR, 'all');   % This fails!!! Fix it.

% When the light sources were all removed, this throws an error.
thisR = piLightAdd(thisR, 'type', 'area', 'lightspectrum', 'D65');

%% END