import json
import uuid
import os

# Define file paths
swift_files = [
    "Dwellable/DwellableApp.swift",
    "Dwellable/Views/LoginView.swift",
    "Dwellable/Views/CaptureView.swift",
    "Dwellable/Views/ReviewView.swift",
    "Dwellable/Views/TranscribingView.swift",
    "Dwellable/Views/AppView.swift",
    "Dwellable/Views/MomentsListView.swift",
    "Dwellable/Views/TypeFlowView.swift",
    "Dwellable/Views/MomentDetailView.swift",
    "Dwellable/Views/MomentRow.swift",
    "Dwellable/Managers/AuthManager.swift",
    "Dwellable/Managers/AudioRecordingManager.swift",
    "Dwellable/Managers/TranscriptionManager.swift",
    "Dwellable/Managers/APIClient.swift",
    "Dwellable/Managers/MockAPIClient.swift",
    "Dwellable/Managers/SupabaseAPIClient.swift",
    "Dwellable/Managers/KeychainManager.swift",
    "Dwellable/Managers/LocalStorageManager.swift",
    "Dwellable/Managers/SyncManager.swift",
    "Dwellable/Models/Moment.swift",
    "Dwellable/Utilities/Theme.swift",
    "Dwellable/Config.swift"
]

resource_files = [
]

# Generate pbxproj content
pbxproj_content = '''// !$*UTF8*$!
{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {

/* Begin PBXBuildFile section */
\t\t0100 /* DwellableApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0101 /* DwellableApp.swift */; };
\t\t0102 /* LoginView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0103 /* LoginView.swift */; };
\t\t0104 /* CaptureView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0105 /* CaptureView.swift */; };
\t\t0106 /* ReviewView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0107 /* ReviewView.swift */; };
\t\t012c /* TranscribingView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 012d /* TranscribingView.swift */; };
\t\t0108 /* AppView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0109 /* AppView.swift */; };
\t\t0110 /* MomentsListView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0111 /* MomentsListView.swift */; };
\t\t013e /* TypeFlowView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 013f /* TypeFlowView.swift */; };
\t\t0144 /* MomentDetailView.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0145 /* MomentDetailView.swift */; };
\t\t0146 /* MomentRow.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0147 /* MomentRow.swift */; };
\t\t0112 /* AuthManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0113 /* AuthManager.swift */; };
\t\t0128 /* AudioRecordingManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0129 /* AudioRecordingManager.swift */; };
\t\t012a /* TranscriptionManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 012b /* TranscriptionManager.swift */; };
\t\t012e /* APIClient.swift in Sources */ = {isa = PBXBuildFile; fileRef = 012f /* APIClient.swift */; };
\t\t0132 /* MockAPIClient.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0133 /* MockAPIClient.swift */; };
\t\t0134 /* SupabaseAPIClient.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0135 /* SupabaseAPIClient.swift */; };
\t\t0136 /* KeychainManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0137 /* KeychainManager.swift */; };
\t\t013a /* LocalStorageManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 013b /* LocalStorageManager.swift */; };
\t\t013c /* SyncManager.swift in Sources */ = {isa = PBXBuildFile; fileRef = 013d /* SyncManager.swift */; };
\t\t0114 /* Moment.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0115 /* Moment.swift */; };
\t\t0116 /* Theme.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0117 /* Theme.swift */; };
\t\t0118 /* Config.swift in Sources */ = {isa = PBXBuildFile; fileRef = 0119 /* Config.swift */; };
\t\t0122 /* UIKit.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 0123 /* UIKit.framework */; };
\t\t0124 /* SwiftUI.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 0125 /* SwiftUI.framework */; };
\t\t0126 /* Foundation.framework in Frameworks */ = {isa = PBXBuildFile; fileRef = 0127 /* Foundation.framework */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
\t\t0101 /* DwellableApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = DwellableApp.swift; sourceTree = "<group>"; };
\t\t0103 /* LoginView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LoginView.swift; sourceTree = "<group>"; };
\t\t0105 /* CaptureView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CaptureView.swift; sourceTree = "<group>"; };
\t\t0107 /* ReviewView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ReviewView.swift; sourceTree = "<group>"; };
\t\t012d /* TranscribingView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TranscribingView.swift; sourceTree = "<group>"; };
\t\t0109 /* AppView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AppView.swift; sourceTree = "<group>"; };
\t\t0111 /* MomentsListView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MomentsListView.swift; sourceTree = "<group>"; };
\t\t013f /* TypeFlowView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TypeFlowView.swift; sourceTree = "<group>"; };
\t\t0145 /* MomentDetailView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MomentDetailView.swift; sourceTree = "<group>"; };
\t\t0147 /* MomentRow.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MomentRow.swift; sourceTree = "<group>"; };
\t\t0113 /* AuthManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AuthManager.swift; sourceTree = "<group>"; };
\t\t0129 /* AudioRecordingManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AudioRecordingManager.swift; sourceTree = "<group>"; };
\t\t012b /* TranscriptionManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TranscriptionManager.swift; sourceTree = "<group>"; };
\t\t012f /* APIClient.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = APIClient.swift; sourceTree = "<group>"; };
\t\t0133 /* MockAPIClient.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MockAPIClient.swift; sourceTree = "<group>"; };
\t\t0135 /* SupabaseAPIClient.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SupabaseAPIClient.swift; sourceTree = "<group>"; };
\t\t0137 /* KeychainManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = KeychainManager.swift; sourceTree = "<group>"; };
\t\t013b /* LocalStorageManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LocalStorageManager.swift; sourceTree = "<group>"; };
\t\t013d /* SyncManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SyncManager.swift; sourceTree = "<group>"; };
\t\t0115 /* Moment.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Moment.swift; sourceTree = "<group>"; };
\t\t0117 /* Theme.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Theme.swift; sourceTree = "<group>"; };
\t\t0119 /* Config.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Config.swift; sourceTree = "<group>"; };
\t\t0121 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
\t\t0123 /* UIKit.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = UIKit.framework; path = System/Library/Frameworks/UIKit.framework; sourceTree = SDKROOT; };
\t\t0125 /* SwiftUI.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = SwiftUI.framework; path = System/Library/Frameworks/SwiftUI.framework; sourceTree = SDKROOT; };
\t\t0127 /* Foundation.framework */ = {isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = Foundation.framework; path = System/Library/Frameworks/Foundation.framework; sourceTree = SDKROOT; };
\t\t0130 /* Dwellable.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Dwellable.app; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
\t\t0140 /* Frameworks */ = {
\t\t\tisa = PBXFrameworksBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t0122 /* UIKit.framework in Frameworks */,
\t\t\t\t0124 /* SwiftUI.framework in Frameworks */,
\t\t\t\t0126 /* Foundation.framework in Frameworks */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
\t\t0001 /* Dwellable */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0101 /* DwellableApp.swift */,
\t\t\t\t0150 /* Views */,
\t\t\t\t0151 /* Managers */,
\t\t\t\t0152 /* Models */,
\t\t\t\t0153 /* Utilities */,
\t\t\t\t0119 /* Config.swift */,
\t\t\t\t0121 /* Info.plist */,
\t\t\t);
\t\t\tpath = Dwellable;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0150 /* Views */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0103 /* LoginView.swift */,
\t\t\t\t0105 /* CaptureView.swift */,
\t\t\t\t0107 /* ReviewView.swift */,
\t\t\t\t012d /* TranscribingView.swift */,
\t\t\t\t0109 /* AppView.swift */,
\t\t\t\t0111 /* MomentsListView.swift */,
\t\t\t\t013f /* TypeFlowView.swift */,
\t\t\t\t0145 /* MomentDetailView.swift */,
\t\t\t\t0147 /* MomentRow.swift */,
\t\t\t);
\t\t\tpath = Views;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0151 /* Managers */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0113 /* AuthManager.swift */,
\t\t\t\t0129 /* AudioRecordingManager.swift */,
\t\t\t\t012b /* TranscriptionManager.swift */,
\t\t\t\t012f /* APIClient.swift */,
\t\t\t\t0133 /* MockAPIClient.swift */,
\t\t\t\t0135 /* SupabaseAPIClient.swift */,
\t\t\t\t0137 /* KeychainManager.swift */,
\t\t\t\t013b /* LocalStorageManager.swift */,
\t\t\t\t013d /* SyncManager.swift */,
\t\t\t);
\t\t\tpath = Managers;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0152 /* Models */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0115 /* Moment.swift */,
\t\t\t);
\t\t\tpath = Models;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0153 /* Utilities */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0117 /* Theme.swift */,
\t\t\t);
\t\t\tpath = Utilities;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0160 /* Frameworks */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0123 /* UIKit.framework */,
\t\t\t\t0125 /* SwiftUI.framework */,
\t\t\t\t0127 /* Foundation.framework */,
\t\t\t);
\t\t\tname = Frameworks;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0170 /* Products */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0130 /* Dwellable.app */,
\t\t\t);
\t\t\tname = Products;
\t\t\tsourceTree = "<group>";
\t\t};
\t\t0180 /* Project */ = {
\t\t\tisa = PBXGroup;
\t\t\tchildren = (
\t\t\t\t0001 /* Dwellable */,
\t\t\t\t0170 /* Products */,
\t\t\t\t0160 /* Frameworks */,
\t\t\t);
\t\t\tsourceTree = "<group>";
\t\t};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
\t\t0010 /* Dwellable */ = {
\t\t\tisa = PBXNativeTarget;
\t\t\tbuildConfigurationList = 0011 /* Build configuration list for PBXNativeTarget "Dwellable" */;
\t\t\tbuildPhases = (
\t\t\t\t0141 /* Sources */,
\t\t\t\t0142 /* Resources */,
\t\t\t\t0140 /* Frameworks */,
\t\t\t);
\t\t\tbuildRules = (
\t\t\t);
\t\t\tdependencies = (
\t\t\t);
\t\t\tname = Dwellable;
\t\t\tproductName = Dwellable;
\t\t\tproductReference = 0130 /* Dwellable.app */;
\t\t\tproductType = "com.apple.product-type.application";
\t\t};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
\t\t0015 /* Project object */ = {
\t\t\tisa = PBXProject;
\t\t\tattributes = {
\t\t\t\tBuildIndependentTargetsInParallel = YES;
\t\t\t\tLastUpgradeCheck = 2630;
\t\t\t};
\t\t\tbuildConfigurationList = 0016 /* Build configuration list for PBXProject "Dwellable" */;
\t\t\tcompatibilityVersion = "Xcode 14.0";
\t\t\tdevelopmentRegion = en;
\t\t\thasScannedForEncodings = 0;
\t\t\tknownRegions = (
\t\t\t\ten,
\t\t\t\tBase,
\t\t\t);
\t\t\tmainGroup = 0180 /* Project */;
\t\t\tproductRefGroup = 0170 /* Products */;
\t\t\tprojectDirPath = "";
\t\t\tprojectRoot = "";
\t\t\ttargets = (
\t\t\t\t0010 /* Dwellable */,
\t\t\t);
\t\t};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
\t\t0142 /* Resources */ = {
\t\t\tisa = PBXResourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
\t\t0141 /* Sources */ = {
\t\t\tisa = PBXSourcesBuildPhase;
\t\t\tbuildActionMask = 2147483647;
\t\t\tfiles = (
\t\t\t\t0100 /* DwellableApp.swift in Sources */,
\t\t\t\t0102 /* LoginView.swift in Sources */,
\t\t\t\t0104 /* CaptureView.swift in Sources */,
\t\t\t\t0106 /* ReviewView.swift in Sources */,
\t\t\t\t012c /* TranscribingView.swift in Sources */,
\t\t\t\t0108 /* AppView.swift in Sources */,
\t\t\t\t0110 /* MomentsListView.swift in Sources */,
\t\t\t\t013e /* TypeFlowView.swift in Sources */,
\t\t\t\t0144 /* MomentDetailView.swift in Sources */,
\t\t\t\t0146 /* MomentRow.swift in Sources */,
\t\t\t\t0112 /* AuthManager.swift in Sources */,
\t\t\t\t0128 /* AudioRecordingManager.swift in Sources */,
\t\t\t\t012a /* TranscriptionManager.swift in Sources */,
\t\t\t\t012e /* APIClient.swift in Sources */,
\t\t\t\t0132 /* MockAPIClient.swift in Sources */,
\t\t\t\t0134 /* SupabaseAPIClient.swift in Sources */,
\t\t\t\t0136 /* KeychainManager.swift in Sources */,
\t\t\t\t013a /* LocalStorageManager.swift in Sources */,
\t\t\t\t013c /* SyncManager.swift in Sources */,
\t\t\t\t0114 /* Moment.swift in Sources */,
\t\t\t\t0116 /* Theme.swift in Sources */,
\t\t\t\t0118 /* Config.swift in Sources */,
\t\t\t);
\t\t\trunOnlyForDeploymentPostprocessing = 0;
\t\t};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
\t\t0013 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_IDENTITY = "iPhone Developer";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = 38X95M6CUB;
\t\t\t\tINFOPLIST_FILE = Dwellable/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.kellgolden.Dwell;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.9;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\t0014 /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tASETCATALOG_COMPILER_APPICON_NAME = AppIcon;
\t\t\t\tCODE_SIGN_IDENTITY = "iPhone Developer";
\t\t\t\tCODE_SIGN_STYLE = Automatic;
\t\t\t\tCURRENT_PROJECT_VERSION = 1;
\t\t\t\tDEVELOPMENT_TEAM = 38X95M6CUB;
\t\t\t\tINFOPLIST_FILE = Dwellable/Info.plist;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMARKETING_VERSION = 1.0;
\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.kellgolden.Dwell;
\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";
\t\t\t\tSWIFT_VERSION = 5.9;
\t\t\t\tTARGETED_DEVICE_FAMILY = 1;
\t\t\t};
\t\t\tname = Release;
\t\t};
\t\t0018 /* Debug */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_DIALECT = "gnu++20";
\t\t\t\tCLANG_CXX_LIBRARY = "libc++";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVES = YES;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tENABLE_TESTABILITY = YES;
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (
\t\t\t\t\t"DEBUG=1",
\t\t\t\t\t"$(inherited)",
\t\t\t\t);
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tONLY_ACTIVE_ARCH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t};
\t\t\tname = Debug;
\t\t};
\t\t0019 /* Release */ = {
\t\t\tisa = XCBuildConfiguration;
\t\t\tbuildSettings = {
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
\t\t\t\tCLANG_CXX_LANGUAGE_DIALECT = "gnu++20";
\t\t\t\tCLANG_CXX_LIBRARY = "libc++";
\t\t\t\tCLANG_ENABLE_MODULES = YES;
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;
\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_COMMA = YES;
\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;
\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;
\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;
\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;
\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;
\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;
\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVES = YES;
\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;
\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
\t\t\t\tCOPY_PHASE_STRIP = NO;
\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
\t\t\t\tENABLE_NS_ASSERTIONS = NO;
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;
\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;
\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;
\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;
\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;
\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 16.0;
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;
\t\t\t\tMTL_FAST_MATH = YES;
\t\t\t\tSDKROOT = iphoneos;
\t\t\t\tVALIDATE_PRODUCT = YES;
\t\t\t};
\t\t\tname = Release;
\t\t};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
\t\t0011 /* Build configuration list for PBXNativeTarget "Dwellable" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t0013 /* Debug */,
\t\t\t\t0014 /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Debug;
\t\t};
\t\t0016 /* Build configuration list for PBXProject "Dwellable" */ = {
\t\t\tisa = XCConfigurationList;
\t\t\tbuildConfigurations = (
\t\t\t\t0018 /* Debug */,
\t\t\t\t0019 /* Release */,
\t\t\t);
\t\t\tdefaultConfigurationIsVisible = 0;
\t\t\tdefaultConfigurationName = Debug;
\t\t};
/* End XCConfigurationList section */

\t};
\trootObject = 0015 /* Project object */;
}
'''

# Write the pbxproj file
with open('Dwellable.xcodeproj/project.pbxproj', 'w') as f:
    f.write(pbxproj_content)

print("pbxproj file generated successfully")
