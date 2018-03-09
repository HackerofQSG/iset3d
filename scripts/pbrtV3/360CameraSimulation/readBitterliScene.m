function [recipe,rigOrigin] = readBitterliScene(sceneName)
%READBITTERLISCENE Load a PBRT scene file from a collection of scenes. We
%also return a good (x,y,z) location for a 360 camera position. These
%scenes are all from Benedikt Bitterli
%(https://benedikt-bitterli.me/resources/) but modified to include more
%lights and to be compatible with the pbrt2ISET parser. The rig origin
%locations were chosen manually; they tend to be near the center of
%the room at roughly 5-6 ft above the ground.
% Currently the available scenes are
% 'whiteRoom','livingRoom','bathroom','kitchen','bathroom2', and 'bedroom'

% Hard coded at the moment.
sceneDir = '/sni-storage/wandell/users/tlian/360Scenes/scenes';

if(~exist(sceneDir,'dir'))
    error(['Scene directory "%s" not found. \n'...
        'Please download the scene data and change the sceneDir'...
        'variable in "readBitterliScene.m" manually.\n In the future,'...
        'we will push these scenes onto a server, and this function will'...
        'downlaod the scene data requested with every call.'],sceneDir);
end

switch sceneName
    case('whiteRoom')
        pbrtFile = fullfile(sceneDir,'living-room-2','scene.pbrt');
        rigOrigin = [0.9476 1.3018 3.4785] + [0 0.600 0];
    case('livingRoom')
        pbrtFile = fullfile(sceneDir,'living-room','scene.pbrt');
        rigOrigin = [2.7007    1.5571   -1.6591];
    case('bathroom')
        pbrtFile = fullfile(sceneDir,'bathroom','scene.pbrt');
        rigOrigin = [0.3   1.667   -1.5];
    case('kitchen')
        pbrtFile = fullfile(sceneDir,'kitchen','scene.pbrt');
        rigOrigin = [0.1768    1.7000   -0.2107];
    case('bathroom2')
        pbrtFile = fullfile(sceneDir,'bathroom2','scene.pbrt');
        rigOrigin = [];
    case('bedroom')
        pbrtFile = fullfile(sceneDir,'bedroom','scene.pbrt');
        rigOrigin = [1.1854    1.1615    1.3385];
    otherwise
        error('Scene not recognized.');
end

if(isempty(rigOrigin))
    warning('Rig origin not set for this scene yet.')
end

recipe = piRead(pbrtFile,'version',3);
end

