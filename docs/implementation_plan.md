# Implementation Plan - Lift App Enhancements

This plan outlines the steps to transition the app from LBS to KG and to enhance the `ProgressionView` with new stats, an improved exercise selection UI, and educational tooltips.

## User Review Required

> [!IMPORTANT]
> The app will transition from LBS to KG. I will rename internal properties (e.g., `weightLbs` to `weightKg`) and update all UI labels. This assumes a 1:1 replacement in the internal logic, as the user requested removing LBS entirely.

## Proposed Changes

### 1. Unit Transition (LBS to KG)

#### [MODIFY] [WorkoutSet.swift](file:///Users/yashvardhanarora/Desktop/GitHub/Lift/Lift/Models/WorkoutSet.swift)
- Rename `weightLbs` to `weightKg`.
- Update `estimatedOneRepMax` and `volume` to use `weightKg`.

#### [MODIFY] [WorkoutExercise.swift](file:///Users/yashvardhanarora/Desktop/GitHub/Lift/Lift/Models/WorkoutExercise.swift)
- Update comments to reflect KG instead of LBS.

#### [MODIFY] [Workout.swift](file:///Users/yashvardhanarora/Desktop/GitHub/Lift/Lift/Models/Workout.swift)
- Rename `totalVolumeLbs` to `totalVolumeKg`.
- Update `totalVolumeFormatted` to use "KG" instead of "LBS".

#### [MODIFY] [Global UI Update]
- Search and replace all literal "LBS" strings with "KG".
- Update `NumberInputField.swift` previews or default placeholders if they explicitly use "LBS".
- Update `ProgressionViewModel.swift` `yLabel` property.

### 2. ProgressionView Enhancements

#### [MODIFY] [ProgressionViewModel.swift](file:///Users/yashvardhanarora/Desktop/GitHub/Lift/Lift/ViewModels/ProgressionViewModel.swift)
- Add new properties:
    - `avgSessionTime: String`
    - `avgSessionFrequency: String`
- Add logic to calculate these stats from all workouts fetched via the repository.
- Add logic to sort `availableExercises` by frequency of use.

#### [MODIFY] [ProgressionView.swift](file:///Users/yashvardhanarora/Desktop/GitHub/Lift/Lift/Screens/Progression/ProgressionView.swift)
- **Top Section:** Add a new `statsOverview` section at the top (before `exerciseHeader`) showing Avg Session Time and Avg Frequency.
- **Exercise Header:** 
    - Replace the static `Text` with a `Menu` or similar interactable dropdown.
    - Style the selected exercise label to look interactable (e.g., add a chevron or subtle background).
    - Remove the toolbar item for exercise selection.
- **Tooltips:**
    - Add info icons next to "VOLUME" and "1RM" in the metric selector or KPI section.
    - Implement tooltips explaining:
        - **Volume:** Total weight moved (Weight x Reps x Sets).
        - **1RM:** Estimated maximum weight for a single repetition.

## Verification Plan

### Automated Tests
- N/A (Project uses manual verification for UI mostly, but I will ensure code compiles).

### Manual Verification
1.  Check `ProgressionView` for the new top stats section.
2.  Verify the exercise label is clickable and shows a sorted dropdown.
3.  Check all weight-related labels to ensure they say "KG".
4.  Verify tooltips appear and show correct explanations.
5.  Perform a "Quick Workout" and ensure weight is logged in KG and reflects in progression.
