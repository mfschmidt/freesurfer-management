#!/usr/bin/python3

from collections import OrderedDict


# This file is no more than dictionaries to look up local database names
# in relation to the names used in FreeSurfer. This makes maintaining
# code easy if FreeSurfer changes things in a future release or if our
# own mapping changes, or if we decide to grab more data for analyses.

# The dictionaries MUST be ordered so that we can write the same variables
# to CSV files in the same order each time. The header is only written
# once and the rest of the entries MUST have the same variables in the
# same order, with a 0 or NA placeholder if they're empty.


# Map from mrs to its description from the published ARIC data dictionary
def get_mrs_dict(which_version):
    default_dict = OrderedDict([
        ('mrs8', 'bankssts_L'),
        ('mrs9', 'bankssts_R'),
        ('mrs10', 'bankssts_T'),
        ('mrs11', 'caudalanteriorcingulate_L'),
        ('mrs12', 'caudalanteriorcingulate_R'),
        ('mrs13', 'caudalanteriorcingulate_T'),
        ('mrs14', 'caudalmiddlefrontal_L'),
        ('mrs15', 'caudalmiddlefrontal_R'),
        ('mrs16', 'caudalmiddlefrontal_T'),
        ('mrs17', 'cuneus_L'),
        ('mrs18', 'cuneus_R'),
        ('mrs19', 'cuneus_T'),
        ('mrs20', 'entorhinal_L'),
        ('mrs21', 'entorhinal_R'),
        ('mrs22', 'entorhinal_T'),
        ('mrs23', 'fusiform_L'),
        ('mrs24', 'fusiform_R'),
        ('mrs25', 'fusiform_T'),
        ('mrs26', 'inferiorparietal_L'),
        ('mrs27', 'inferiorparietal_R'),
        ('mrs28', 'inferiorparietal_T'),
        ('mrs29', 'inferiortemporal_L'),
        ('mrs30', 'inferiortemporal_R'),
        ('mrs31', 'inferiortemporal_T'),
        ('mrs32', 'isthmuscingulate_L'),
        ('mrs33', 'isthmuscingulate_R'),
        ('mrs34', 'isthmuscingulate_T'),
        ('mrs35', 'lateraloccipital_L'),
        ('mrs36', 'lateraloccipital_R'),
        ('mrs37', 'lateraloccipital_T'),
        ('mrs38', 'lateralorbitofrontal_L'),
        ('mrs39', 'lateralorbitofrontal_R'),
        ('mrs40', 'lateralorbitofrontal_T'),
        ('mrs41', 'lingual_L'),
        ('mrs42', 'lingual_R'),
        ('mrs43', 'lingual_T'),
        ('mrs44', 'medialorbitofrontal_L'),
        ('mrs45', 'medialorbitofrontal_R'),
        ('mrs46', 'medialorbitofrontal_T'),
        ('mrs47', 'middletemporal_L'),
        ('mrs48', 'middletemporal_R'),
        ('mrs49', 'middletemporal_T'),
        ('mrs50', 'parahippocampal_L'),
        ('mrs51', 'parahippocampal_R'),
        ('mrs52', 'parahippocampal_T'),
        ('mrs53', 'paracentral_L'),
        ('mrs54', 'paracentral_R'),
        ('mrs55', 'paracentral_T'),
        ('mrs56', 'parsopercularis_L'),
        ('mrs57', 'parsopercularis_R'),
        ('mrs58', 'parsopercularis_T'),
        ('mrs59', 'parsorbitalis_L'),
        ('mrs60', 'parsorbitalis_R'),
        ('mrs61', 'parsorbitalis_T'),
        ('mrs62', 'parstriangularis_L'),
        ('mrs63', 'parstriangularis_R'),
        ('mrs64', 'parstriangularis_T'),
        ('mrs65', 'pericalcarine_L'),
        ('mrs66', 'pericalcarine_R'),
        ('mrs67', 'pericalcarine_T'),
        ('mrs68', 'postcentral_L'),
        ('mrs69', 'postcentral_R'),
        ('mrs70', 'postcentral_T'),
        ('mrs71', 'posteriorcingulate_L'),
        ('mrs72', 'posteriorcingulate_R'),
        ('mrs73', 'posteriorcingulate_T'),
        ('mrs74', 'precentral_L'),
        ('mrs75', 'precentral_R'),
        ('mrs76', 'precentral_T'),
        ('mrs77', 'precuneus_L'),
        ('mrs78', 'precuneus_R'),
        ('mrs79', 'precuneus_T'),
        ('mrs80', 'rostralanteriorcingulate_L'),
        ('mrs81', 'rostralanteriorcingulate_R'),
        ('mrs82', 'rostralanteriorcingulate_T'),
        ('mrs83', 'rostralmiddlefrontal_L'),
        ('mrs84', 'rostralmiddlefrontal_R'),
        ('mrs85', 'rostralmiddlefrontal_T'),
        ('mrs86', 'superiorfrontal_L'),
        ('mrs87', 'superiorfrontal_R'),
        ('mrs88', 'superiorfrontal_T'),
        ('mrs89', 'superiorparietal_L'),
        ('mrs90', 'superiorparietal_R'),
        ('mrs91', 'superiorparietal_T'),
        ('mrs92', 'superiortemporal_L'),
        ('mrs93', 'superiortemporal_R'),
        ('mrs94', 'superiortemporal_T'),
        ('mrs95', 'supramarginal_L'),
        ('mrs96', 'supramarginal_R'),
        ('mrs97', 'supramarginal_T'),
        ('mrs98', 'frontalpole_L'),
        ('mrs99', 'frontalpole_R'),
        ('mrs100', 'frontalpole_T'),
        ('mrs101', 'temporalpole_L'),
        ('mrs102', 'temporalpole_R'),
        ('mrs103', 'temporalpole_T'),
        ('mrs104', 'transversetemporal_L'),
        ('mrs105', 'transversetemporal_R'),
        ('mrs106', 'transversetemporal_T'),
        ('mrs107', 'insula_L'),
        ('mrs108', 'insula_R'),
        ('mrs109', 'insula_T'),
        ('mrs110', 'Left-Thalamus-Proper'),
        ('mrs111', 'Right-Thalamus-Proper'),
        ('mrs112', 'ThalamusProper_T'),
        ('mrs113', 'Left-Caudate'),
        ('mrs114', 'Right-Caudate'),
        ('mrs115', 'Caudate_T'),
        ('mrs116', 'Left-Putamen'),
        ('mrs117', 'Right-Putamen'),
        ('mrs118', 'Putamen_T'),
        ('mrs119', 'Left-Pallidum'),
        ('mrs120', 'Right-Pallidum'),
        ('mrs121', 'Pallidum_T'),
        ('mrs122', 'Left-Hippocampus'),
        ('mrs123', 'Right-Hippocampus'),
        ('mrs124', 'Hippocampus_T'),
        ('mrs125', 'Left-Amygdala'),
        ('mrs126', 'Right-Amygdala'),
        ('mrs127', 'Amygdala_T'),
        ('mrs128', 'Vetrical_T'),
        ('mrs129', 'eTIV'),
        ('mrs3M', 'Scandate_Month'),
        ('mrs3D', 'Scandate_Day'),
        ('mrs3Y', 'Scandate_Year'),
        ('mrs3T', 'Scandate_Time'),
        ('mrs7M', 'Analysisdate_Month'),
        ('mrs7D', 'Analysisdate_Day'),
        ('mrs7Y', 'Analysisdate_Year'),
        ('mrs7T', 'Analysisdate_Time'),
        ('FormStatusMRS', 'Form_Status'),
        ('LoginNameMRS', 'Login_Name'),
        ('LocationNameMRS', 'Location_Name'),
        ('DateStampInitialMRS', 'Date_Stamp_Initial'),
        ('TimeStampInitialMRS', 'Time_Stamp_Initial'),
    ])
    if which_version in ["5.2.0", "5.3.0", "6.0.0"]:
        return default_dict
    else:
        print("Version {0} is not supported by get_mrs_dict".format(which_version))
        return OrderedDict()


# Map from FreeSurfer's wmparc.stats file to mrs variable
def get_wmparc_dict(which_version):
    default_dict = OrderedDict([
        ('lhCorticalWhiteMatterVol', 'mrs'),
        ('rhCorticalWhiteMatterVol', 'mrs'),
        ('CorticalWhiteMatterVol', 'mrs'),
        ('MaskVol', 'mrs'),
        ('eTIV', 'mrs'),
        ('wm-lh-bankssts', 'mrs'),
        ('wm-lh-caudalanteriorcingulate', 'mrs'),
        ('wm-lh-caudalmiddlefrontal', 'mrs'),
        ('wm-lh-cuneus', 'mrs'),
        ('wm-lh-entorhinal', 'mrs'),
        ('wm-lh-fusiform', 'mrs'),
        ('wm-lh-inferiorparietal', 'mrs'),
        ('wm-lh-inferiortemporal', 'mrs'),
        ('wm-lh-isthmuscingulate', 'mrs'),
        ('wm-lh-lateraloccipital', 'mrs'),
        ('wm-lh-lateralorbitofrontal', 'mrs'),
        ('wm-lh-lingual', 'mrs'),
        ('wm-lh-medialorbitofrontal', 'mrs'),
        ('wm-lh-middletemporal', 'mrs'),
        ('wm-lh-parahippocampal', 'mrs'),
        ('wm-lh-paracentral', 'mrs'),
        ('wm-lh-parsopercularis', 'mrs'),
        ('wm-lh-parsorbitalis', 'mrs'),
        ('wm-lh-parstriangularis', 'mrs'),
        ('wm-lh-pericalcarine', 'mrs'),
        ('wm-lh-postcentral', 'mrs'),
        ('wm-lh-posteriorcingulate', 'mrs'),
        ('wm-lh-precentral', 'mrs'),
        ('wm-lh-precuneus', 'mrs'),
        ('wm-lh-rostralanteriorcingulate', 'mrs'),
        ('wm-lh-rostralmiddlefrontal', 'mrs'),
        ('wm-lh-superiorfrontal', 'mrs'),
        ('wm-lh-superiorparietal', 'mrs'),
        ('wm-lh-superiortemporal', 'mrs'),
        ('wm-lh-supramarginal', 'mrs'),
        ('wm-lh-frontalpole', 'mrs'),
        ('wm-lh-temporalpole', 'mrs'),
        ('wm-lh-transversetemporal', 'mrs'),
        ('wm-lh-insula', 'mrs'),
        ('wm-rh-bankssts', 'mrs'),
        ('wm-rh-caudalanteriorcingulate', 'mrs'),
        ('wm-rh-caudalmiddlefrontal', 'mrs'),
        ('wm-rh-cuneus', 'mrs'),
        ('wm-rh-entorhinal', 'mrs'),
        ('wm-rh-fusiform', 'mrs'),
        ('wm-rh-inferiorparietal', 'mrs'),
        ('wm-rh-inferiortemporal', 'mrs'),
        ('wm-rh-isthmuscingulate', 'mrs'),
        ('wm-rh-lateraloccipital', 'mrs'),
        ('wm-rh-lateralorbitofrontal', 'mrs'),
        ('wm-rh-lingual', 'mrs'),
        ('wm-rh-medialorbitofrontal', 'mrs'),
        ('wm-rh-middletemporal', 'mrs'),
        ('wm-rh-parahippocampal', 'mrs'),
        ('wm-rh-paracentral', 'mrs'),
        ('wm-rh-parsopercularis', 'mrs'),
        ('wm-rh-parsorbitalis', 'mrs'),
        ('wm-rh-parstriangularis', 'mrs'),
        ('wm-rh-pericalcarine', 'mrs'),
        ('wm-rh-postcentral', 'mrs'),
        ('wm-rh-posteriorcingulate', 'mrs'),
        ('wm-rh-precentral', 'mrs'),
        ('wm-rh-precuneus', 'mrs'),
        ('wm-rh-rostralanteriorcingulate', 'mrs'),
        ('wm-rh-rostralmiddlefrontal', 'mrs'),
        ('wm-rh-superiorfrontal', 'mrs'),
        ('wm-rh-superiorparietal', 'mrs'),
        ('wm-rh-superiortemporal', 'mrs'),
        ('wm-rh-supramarginal', 'mrs'),
        ('wm-rh-frontalpole', 'mrs'),
        ('wm-rh-temporalpole', 'mrs'),
        ('wm-rh-transversetemporal', 'mrs'),
        ('wm-rh-insula', 'mrs'),
        ('Left-UnsegmentedWhiteMatter', 'mrs'),
        ('Right-UnsegmentedWhiteMatter', 'mrs'),
    ])
    if which_version in ["5.2.0", "5.3.0"]:
        return default_dict
    elif which_version in ["6.0.0"]:
        different_dict = OrderedDict([
            ('lhCerebralWhiteMatterVol', v) if k == 'lhCorticalWhiteMatterVol' else
            ('rhCerebralWhiteMatterVol', v) if k == 'rhCorticalWhiteMatterVol' else
            ('CerebralWhiteMatterVol', v) if k == 'CorticalWhiteMatterVol' else
            (k, v) for k, v in default_dict.items()
        ])
        return different_dict
    else:
        print("Version {0} is not supported by get_wmparc_dict".format(which_version))
        return OrderedDict()


# Map from FreeSurfer's aseg.stats file to mrs variable
def get_aseg_dict(which_version):
    default_dict = OrderedDict([
        ('BrainSegVol', 'mrs'),
        ('BrainSegVolNotVent', 'mrs'),
        ('BrainSegVolNotVentSurf', 'mrs'),
        ('VentricleChoroidVol', 'mrs'),
        ('lhCortexVol', 'mrs'),
        ('rhCortexVol', 'mrs'),
        ('CortexVol', 'mrs'),
        ('lhCorticalWhiteMatterVol', 'mrs'),
        ('rhCorticalWhiteMatterVol', 'mrs'),
        ('CorticalWhiteMatterVol', 'mrs'),
        ('SubCortGrayVol', 'mrs'),
        ('TotalGrayVol', 'mrs'),
        ('SupraTentorialVol', 'mrs'),
        ('SupraTentorialVolNotVent', 'mrs'),
        ('SupraTentorialVolNotVentVox', 'mrs'),
        ('MaskVol', 'mrs'),
        ('BrainSegVol-to-eTIV', 'mrs'),
        ('MaskVol-to-eTIV', 'mrs'),
        ('lhSurfaceHoles', 'mrs'),
        ('rhSurfaceHoles', 'mrs'),
        ('SurfaceHoles', 'mrs'),
        ('eTIV', 'mrs'),
        ('Left-Lateral-Ventricle', 'mrs'),
        ('Left-Inf-Lat-Vent', 'mrs'),
        ('Left-Cerebellum-White-Matter', 'mrs'),
        ('Left-Cerebellum-Cortex', 'mrs'),
        ('Left-Thalamus-Proper', 'mrs110'),
        ('Left-Caudate', 'mrs113'),
        ('Left-Putamen', 'mrs116'),
        ('Left-Pallidum', 'mrs119'),
        ('3rd-Ventricle', 'mrs'),
        ('4th-Ventricle', 'mrs'),
        ('Brain-Stem', 'mrs'),
        ('Left-Hippocampus', 'mrs122'),
        ('Left-Amygdala', 'mrs125'),
        ('CSF', 'mrs'),
        ('Left-Accumbens-area', 'mrs'),
        ('Left-VentralDC', 'mrs'),
        ('Left-vessel', 'mrs'),
        ('Left-choroid-plexus', 'mrs'),
        ('Right-Lateral-Ventricle', 'mrs'),
        ('Right-Inf-Lat-Vent', 'mrs'),
        ('Right-Cerebellum-White-Matter', 'mrs'),
        ('Right-Cerebellum-Cortex', 'mrs'),
        ('Right-Thalamus-Proper', 'mrs111'),
        ('Right-Caudate', 'mrs114'),
        ('Right-Putamen', 'mrs117'),
        ('Right-Pallidum', 'mrs120'),
        ('Right-Hippocampus', 'mrs123'),
        ('Right-Amygdala', 'mrs126'),
        ('Right-Accumbens-area', 'mrs'),
        ('Right-VentralDC', 'mrs'),
        ('Right-vessel', 'mrs'),
        ('Right-choroid-plexus', 'mrs'),
        ('5th-Ventricle', 'mrs'),
        ('WM-hypointensities', 'mrs'),
        ('Left-WM-hypointensities', 'mrs'),
        ('Right-WM-hypointensities', 'mrs'),
        ('non-WM-hypointensities', 'mrs'),
        ('Left-non-WM-hypointensities', 'mrs'),
        ('Right-non-WM-hypointensities', 'mrs'),
        ('Optic-Chiasm', 'mrs'),
        ('CC_Posterior', 'mrs'),
        ('CC_Mid_Posterior', 'mrs'),
        ('CC_Central', 'mrs'),
        ('CC_Mid_Anterior', 'mrs'),
        ('CC_Anterior', 'mrs'),
    ])
    if which_version in ["5.2.0", "5.3.0"]:
        del default_dict['VentricleChoroidVol']
        return default_dict
    elif which_version in ["6.0.0"]:
        different_dict = OrderedDict([
            ('lhCerebralWhiteMatterVol', v) if k == 'lhCorticalWhiteMatterVol' else
            ('rhCerebralWhiteMatterVol', v) if k == 'rhCorticalWhiteMatterVol' else
            ('CerebralWhiteMatterVol', v) if k == 'CorticalWhiteMatterVol' else
            (k, v) for k, v in default_dict.items()
        ])
        return different_dict
    else:
        print("Version {0} is not supported by get_aseg_dict".format(which_version))
        return OrderedDict()


# Map from FreeSurfer's lh.aparc.stats file to mrs variable
def get_aparc_dict(which_version):
    default_dict = OrderedDict([
        ('NumVert', 'mrs'),
        ('WhiteSurfArea', 'mrs'),
        ('MeanThickness', 'mrs'),
        ('BrainSegVol', 'mrs'),
        ('BrainSegVolNotVent', 'mrs'),
        ('BrainSegVolNotVentSurf', 'mrs'),
        ('CortexVol', 'mrs'),
        ('SupraTentorialVol', 'mrs'),
        ('SupraTentorialVolNotVent', 'mrs'),
        ('eTIV', 'mrs'),
        ('bankssts', 'mrs8'),
        ('caudalanteriorcingulate', 'mrs11'),
        ('caudalmiddlefrontal', 'mrs14'),
        ('cuneus', 'mrs17'),
        ('entorhinal', 'mrs20'),
        ('fusiform', 'mrs23'),
        ('inferiorparietal', 'mrs26'),
        ('inferiortemporal', 'mrs29'),
        ('isthmuscingulate', 'mrs32'),
        ('lateraloccipital', 'mrs35'),
        ('lateralorbitofrontal', 'mrs38'),
        ('lingual', 'mrs41'),
        ('medialorbitofrontal', 'mrs44'),
        ('middletemporal', 'mrs47'),
        ('parahippocampal', 'mrs50'),
        ('paracentral', 'mrs53'),
        ('parsopercularis', 'mrs56'),
        ('parsorbitalis', 'mrs59'),
        ('parstriangularis', 'mrs62'),
        ('pericalcarine', 'mrs65'),
        ('postcentral', 'mrs68'),
        ('posteriorcingulate', 'mrs71'),
        ('precentral', 'mrs74'),
        ('precuneus', 'mrs77'),
        ('rostralanteriorcingulate', 'mrs80'),
        ('rostralmiddlefrontal', 'mrs83'),
        ('superiorfrontal', 'mrs86'),
        ('superiorparietal', 'mrs89'),
        ('superiortemporal', 'mrs92'),
        ('supramarginal', 'mrs95'),
        ('frontalpole', 'mrs98'),
        ('temporalpole', 'mrs101'),
        ('transversetemporal', 'mrs104'),
        ('insula', 'mrs107'),
    ])
    if which_version in ["5.2.0", "5.3.0"]:
        del default_dict['BrainSegVol']
        del default_dict['BrainSegVolNotVent']
        del default_dict['BrainSegVolNotVentSurf']
        del default_dict['CortexVol']
        del default_dict['SupraTentorialVol']
        del default_dict['SupraTentorialVolNotVent']
        del default_dict['eTIV']
        return default_dict
    elif which_version in ["6.0.0"]:
        return default_dict
    else:
        print("Version {0} is not supported by get_aparc_dict".format(which_version))
        return OrderedDict()


# Get list of items in aparc that are whole brain, and reported in both r and l sides
def get_shared_aparc_items():
    return ['BrainSegVol',
            'BrainSegVolNotVent',
            'BrainSegVolNotVentSurf',
            'CortexVol',
            'SupraTentorialVol',
            'SupraTentorialVolNotVent',
            'eTIV',
            ]


# Map from FreeSurfer's lh.hippoSfVolumes-T1.v10.txt file to mrs variable
def get_hsegs_dict(which_version):
    default_dict = OrderedDict([
        ('Hippocampal_tail', 'mrs'),
        ('subiculum', 'mrs'),
        ('CA1', 'mrs'),
        ('hippocampal-fissure', 'mrs'),
        ('presubiculum', 'mrs'),
        ('parasubiculum', 'mrs'),
        ('molecular_layer_HP', 'mrs'),
        ('GC-ML-DG', 'mrs'),
        ('CA3', 'mrs'),
        ('CA4', 'mrs'),
        ('fimbria', 'mrs'),
        ('HATA', 'mrs'),
        ('Whole_hippocampus', 'mrs'),
    ])
    return default_dict



# Extract dictionary of metadata
def get_mrs_meta_dict(subjectid, scandate, fstime):
    return OrderedDict([
        ("ID", subjectid),  # "Label"
        ("SubjectID", subjectid),  # "ARIC Subject ID"
        ("Event", "0"),  # usu 5 in ARIC
        ("EventName", "MFSTOCSV"),  # usu CSCC in ARIC
        ("Occurrence", "0"),  # usu 1 in ARIC
        ("EventID", "0"),  # usu 6-digit sequential num in ARIC
        ("Form", "MRS"),  # usu MRS in ARIC
        ("Vers", "0100"),  # usu 0100 in ARIC
        ("mrs1", subjectid),  # "Participant ID"
        ("mrs2", "NA"),  # "Acrostic ID"
        ("mrs3", scandate),  # "Date of Scan" ISO_8601 format
        ("mrs4", "1.5"),  # "Field Strength of MR Scanner"
        ("mrs5", "NA"),  # "Series Number" 3
        ("mrs6", "NA"),  # "Series Description" 2
        ("mrs7", fstime),  # "Date of Analysis Completed" ISO_8601 format
    ])


# Extract dictionary of metadata
def get_meta_dict(subjectid, fstime):
    return OrderedDict([
        ("ID", subjectid),  # "Label"
        ("fscompletedate", fstime),  # "Date of Analysis Completed" ISO_8601 format
    ])
