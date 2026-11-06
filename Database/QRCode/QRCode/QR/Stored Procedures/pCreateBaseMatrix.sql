
-- ##############################################################################
-- ### Procedure: [QR].[pCreateBaseMatrix]                                    ###
-- ##############################################################################
-- ### Purpose:                                                               ###
-- ### Creates the complete QR matrix framework required before payload       ###
-- ### placement.                                                             ###
-- ### The procedure places all fixed QR structures defined by the            ###
-- ### specification.                                                         ###
-- ### Internally calls procedures responsible for:                           ###
-- ###   - Finder patterns                                                    ###
-- ###   - Separators                                                         ###
-- ###   - Timing patterns                                                    ###
-- ###   - Alignment patterns                                                 ###
-- ###   - Format information areas                                           ###
-- ###   - Version information areas                                          ###
-- ###   - Dark module                                                        ###
-- ### ---------------------------------------------------------------------- ###
-- ### API Level:                      Internal                               ###
-- ### ---------------------------------------------------------------------- ###
-- ### Input parameters:                                                      ###
-- ### @VersionNumber:                 QR version number                      ###
-- ### ---------------------------------------------------------------------- ###
-- ### Output parameters:                                                     ###
-- ### None                                                                   ###
-- ##############################################################################
CREATE   PROCEDURE [QR].[pCreateBaseMatrix]
    @VersionNumber              TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MatrixSize         INTEGER;
    DECLARE @BorderRight        INTEGER;
    SET @MatrixSize     = [QR].[fnGetMatrixSize](@VersionNumber);
    SET @BorderRight    = @MatrixSize - 7;

    EXEC [QR].[pInitializeMatrix] @VersionNumber = @VersionNumber;

    EXEC [QR].[pSetFinderPattern] 0, 0;
    EXEC [QR].[pSetFinderPattern] @BorderRight, 0;
    EXEC [QR].[pSetFinderPattern] 0, @BorderRight;

    EXEC [QR].[pSetSeparator] 0, 0;
    EXEC [QR].[pSetSeparator] @BorderRight, 0;
    EXEC [QR].[pSetSeparator] 0, @BorderRight;

    EXEC [QR].[pSetTimingPatterns]    @VersionNumber = @VersionNumber;
    EXEC [QR].[pSetAlignmentPatterns] @VersionNumber = @VersionNumber;
    EXEC [QR].[pSetDarkModule]        @VersionNumber = @VersionNumber;
    EXEC [QR].[pReserveFormatModules] @VersionNumber = @VersionNumber;

    EXEC [QR].[pReserveVersionModules]     @VersionNumber = @VersionNumber;
END;
