function piMaterialWrite(thisR)
% Write the material file from PBRT V3, as input from Cinema 4D
%
% The main scene file (scene.pbrt) includes a scene_materials.pbrt
% file.  This routine writes out the materials file from the
% information in the recipe.
%
% ZL, SCIEN STANFORD, 2018

%%
p = inputParser;
p.addRequired('thisR',@(x)isequal(class(x),'recipe'));
p.parse(thisR);

%% Create txtLines for texture struct array
% Texture txt lines creation are moved into piTextureText function.

if isfield(thisR.textures,'list') && ~isempty(thisR.textures.list)
    textureNum = numel(thisR.textures.list);
    textureTxt = cell(1, textureNum);

    for ii = 1:numel(textureTxt)
        textureTxt{ii} = piTextureText(thisR.textures.list{ii});
    end
else
    textureTxt = {};
end

%% Parse the output file, working directory, stuff like that.
% Commented by ZLY. Does this section do any work?

%{
% Converts any jpg file names in the PBRT files into png file names
ntxtLines=length(thisR.materials.txtLines);
for jj = 1:ntxtLines
    str = thisR.materials.txtLines(jj);
    if piContains(str,'.jpg"')
        thisR.materials.txtLines(jj) = strrep(str,'jpg','png');
    end
    if piContains(str,'.jpg "')
        thisR.materials.txtLines(jj) = strrep(str,'jpg ','png');
    end
    % photoshop exports texture format with ".JPG "(with extra space) ext.
    if piContains(str,'.JPG "')
        thisR.materials.txtLines(jj) = strrep(str,'JPG ','png');
    end
    if piContains(str,'.JPG"')
        thisR.materials.txtLines(jj) = strrep(str,'JPG','png');
    end
    if piContains(str,'bmp')
        thisR.materials.txtLines(jj) = strrep(str,'bmp','png');
    end
    if piContains(str,'tif')
        thisR.materials.txtLines(jj) = strrep(str,'tif','png');
    end
end
%}

%% Create txtLines for the material struct array
field =fieldnames(thisR.materials.list);
materialTxt = cell(1,length(field));

for ii=1:length(materialTxt)
    % Converts the material struct to text
    materialTxt{ii} = piMaterialText(thisR.materials.list.(cell2mat(field(ii))));
end

%% Write to scene_material.pbrt texture-material file
output = thisR.materials.outputFile_materials;
fileID = fopen(output,'w');
fprintf(fileID,'# Exported by piMaterialWrite on %i/%i/%i %i:%i:%0.2f \n',clock);

if ~isempty(textureTxt)
    % Add textures
    for row=1:length(textureTxt)
        fprintf(fileID,'%s\n',textureTxt{row});
    end
end

% Add the materials
nPaintLines = {};
gg = 1;
for dd = 1:length(materialTxt)
    if piContains(materialTxt{dd},'paint_base') &&...
            ~piContains(materialTxt{dd},'mix')||...
            piContains(materialTxt{dd},'paint_mirror') &&...
            ~piContains(materialTxt{dd},'mix')
        nPaintLines{gg} = dd;
        gg = gg+1;
    end
end

% Find material names contains 'paint_base' or 'paint_mirror'
if ~isempty(nPaintLines)
    for hh = 1:length(nPaintLines)
        fprintf(fileID,'%s\n',materialTxt{nPaintLines{hh}});
        materialTxt{nPaintLines{hh}} = [];
    end
    materialTxt = materialTxt(~cellfun('isempty',materialTxt));
    %     nmaterialTxt = length(materialTxt)-length(nPaintLines);
    for row=1:length(materialTxt)
        fprintf(fileID,'%s\n',materialTxt{row});
    end
else
    for row=1:length(materialTxt)
        fprintf(fileID,'%s\n',materialTxt{row});
    end
end
fclose(fileID);

[~,n,e] = fileparts(output);
fprintf('Material file %s written successfully.\n', [n,e]);

end

%% function that converts the struct to text
function val = piMaterialText(materials)
% For each type of material, we have a method to write a line in the
% material file.
%

val_name = sprintf('MakeNamedMaterial "%s" ',materials.name);
val = val_name;
val_string = sprintf(' "string type" "%s" ',materials.string);
val = strcat(val, val_string);

if ~isempty(materials.floatindex)
    val_floatindex = sprintf(' "float index" [%0.5f] ',materials.floatindex);
    val = strcat(val, val_floatindex);
end

if ~isempty(materials.texturekd)
    val_texturekd = sprintf(' "texture Kd" "%s" ',materials.texturekd);
    val = strcat(val, val_texturekd);
end

if ~isempty(materials.texturekr)
    val_texturekr = sprintf(' "texture Kr" "%s" ',materials.texturekr);
    val = strcat(val, val_texturekr);
end

if ~isempty(materials.textureks)
    val_textureks = sprintf(' "texture Ks" "%s" ',materials.textureks);
    val = strcat(val, val_textureks);
end

if ~isempty(materials.rgbkr)
    val_rgbkr = sprintf(' "rgb Kr" [%0.5f %0.5f %0.5f] ',materials.rgbkr);
    val = strcat(val, val_rgbkr);
end

if ~isempty(materials.rgbks)
    val_rgbks = sprintf(' "rgb Ks" [%0.5f %0.5f %0.5f] ',materials.rgbks);
    val = strcat(val, val_rgbks);
end

if ~isempty(materials.rgbkt)
    val_rgbkt = sprintf(' "rgb Kt" [%0.5f %0.5f %0.5f] ',materials.rgbkt);
    val = strcat(val, val_rgbkt);
end

if ~isempty(materials.rgbkd)
    val_rgbkd = sprintf(' "rgb Kd" [%0.5f %0.5f %0.5f] ',materials.rgbkd);
    val = strcat(val, val_rgbkd);
end

if ~isempty(materials.colorkd)
    val_colorkd = sprintf(' "color Kd" [%0.5f %0.5f %0.5f] ',materials.colorkd);
    val = strcat(val, val_colorkd);
end

if ~isempty(materials.colorks)
    val_colorks = sprintf(' "color Ks" [%0.5f %0.5f %0.5f] ',materials.colorks);
    val = strcat(val, val_colorks);
end
if isfield(materials, 'colorreflect')
    if ~isempty(materials.colorreflect)
        val_colorreflect = sprintf(' "color reflect" [%0.5f %0.5f %0.5f] ',materials.colorreflect);
        val = strcat(val, val_colorreflect);
    end
    if ~isempty(materials.colortransmit)
        val_colortransmit = sprintf(' "color transmit" [%0.5f %0.5f %0.5f] ',materials.colortransmit);
        val = strcat(val, val_colortransmit);
    end
end
if isfield(materials, 'colormfp')
    if ~isempty(materials.colormfp)
        val_colormfp = sprintf(' "color mfp" [%0.5f %0.5f %0.5f] ',materials.colormfp);
        val = strcat(val, val_colormfp);
    end
end
if ~isempty(materials.floaturoughness)
    val_floaturoughness = sprintf(' "float uroughness" [%0.5f] ',materials.floaturoughness);
    val = strcat(val, val_floaturoughness);
end

if ~isempty(materials.floatvroughness)
    val_floatvroughness = sprintf(' "float vroughness" [%0.5f] ',materials.floatvroughness);
    val = strcat(val, val_floatvroughness);
end

if ~isempty(materials.floatroughness)
    val_floatroughness = sprintf(' "float roughness" [%0.5f] ',materials.floatroughness);
    val = strcat(val, val_floatroughness);
end
 
if isfield(materials,'floateta') && ~isempty(materials.floateta)
    val_floateta = sprintf(' "float eta" [%0.5f] ',materials.floateta);
    val = strcat(val, val_floateta);
end

if ~isempty(materials.spectrumkd)
    if(ischar(materials.spectrumkd))
        val_spectrumkd = sprintf(' "spectrum Kd" "%s" ',materials.spectrumkd);
    else
        val_spectrumkd = sprintf(' "spectrum Kd" [ %s ] ',num2str(materials.spectrumkd)); 
    end
    val = strcat(val, val_spectrumkd);
end

if ~isempty(materials.spectrumks)
    if(ischar(materials.spectrumks))
        val_spectrumks = sprintf(' "spectrum Ks" "%s" ',materials.spectrumks);
    else
        val_spectrumks = sprintf(' "spectrum Ks" [ %s ] ',num2str(materials.spectrumks)); 
    end
    val = strcat(val, val_spectrumks);
end

if isfield(materials, 'spectrumkr')
    if ~isempty(materials.spectrumkr)
        if(isstring(materials.spectrumkr))
            val_spectrumkr = sprintf(' "spectrum Kr" "%s" ',materials.spectrumkr);
        else
            val_spectrumkr = sprintf(' "spectrum Kr" [%0.5f %0.5f %0.5f %0.5f] ',materials.spectrumkr);
        end
        val = strcat(val, val_spectrumkr);
    end
end
if isfield(materials, 'spectrumkt')
    if ~isempty(materials.spectrumkt)
        if(isstring(materials.spectrumkt))
            val_spectrumkt = sprintf(' "spectrum Kt" "%s" ',materials.spectrumkt);
        else
            val_spectrumkt = sprintf(' "spectrum Kt" [%0.5f %0.5f %0.5f %0.5f] ',materials.spectrumkt);
        end
        val = strcat(val, val_spectrumkt);
    end
end
% if ~isempty(materials.spectrumk)
%     val_spectrumks = sprintf(' "spectrum k" "%s" ',materials.spectrumk);
%     val = strcat(val, val_spectrumks);
% end

if ~isempty(materials.spectrumeta)
    val_spectrumks = sprintf(' "spectrum eta" "%s" ',materials.spectrumeta);
    val = strcat(val, val_spectrumks);
end

if ~isempty(materials.stringnamedmaterial1)
    val_stringnamedmaterial1 = sprintf(' "string namedmaterial1" "%s" ',materials.stringnamedmaterial1);
    val = strcat(val, val_stringnamedmaterial1);
end

if isfield(materials, 'bsdffile')
    if ~isempty(materials.bsdffile)
        val_bsdfile = sprintf(' "string bsdffile" "%s" ',materials.bsdffile);
        val = strcat(val, val_bsdfile);
    end
end
if ~isempty(materials.stringnamedmaterial2)
    val_stringnamedmaterial2 = sprintf(' "string namedmaterial2" "%s" ',materials.stringnamedmaterial2);
    val = strcat(val, val_stringnamedmaterial2);
end
if isfield(materials,'texturebumpmap')
    if ~isempty(materials.texturebumpmap)
        val_texturekr = sprintf(' "texture bumpmap" "%s" ',materials.texturebumpmap);
        val = strcat(val, val_texturekr);
    end
end
if isfield(materials, 'boolremaproughness')
    if ~isempty(materials.boolremaproughness)
        val_boolremaproughness = sprintf(' "bool remaproughness" "%s" ',materials.boolremaproughness);
        val = strcat(val, val_boolremaproughness);
    end
end
if isfield(materials, 'eta')
    if ~isempty(materials.eta)
        val_boolremaproughness = sprintf(' "float eta" %0.5f ',materials.eta);
        val = strcat(val, val_boolremaproughness);
    end
end
if isfield(materials, 'amount')
    if ~isempty(materials.amount)
        val_boolremaproughness = sprintf(' "spectrum amount" "%0.5f" ',materials.amount);
        val = strcat(val, val_boolremaproughness);
    end
end
if isfield(materials, 'photolumifluorescence')
    if ~isempty(materials.photolumifluorescence)
        val_photolumifluorescence = [sprintf(' "photolumi fluorescence" '),...
                                    '[ ', sprintf('%.5f ', materials.photolumifluorescence),' ]'];
        val = strcat(val, val_photolumifluorescence);
    end
end
if isfield(materials, 'floatconcentration')
    if ~isempty(materials.floatconcentration)
        val_floatconcentration = sprintf(' "float concentration" [ %0.5f ] ',...
                                    materials.floatconcentration);
        val = strcat(val, val_floatconcentration);
    end
end


end
