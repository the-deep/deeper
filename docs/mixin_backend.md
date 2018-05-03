### Test Mixins

List of Mixin used in Tests

0. AuthMixin
    - Path: *user.tests.test_apis*

1. UserGroupMixin
    - Path: *user_group.tests.test_apis*

2. ProjectMixin
    - Path: *project.tests.test_apis*

3. RegionMixin
    - Path: *geo.tests.test_apis*

4. LeadMixin
    - Path: *lead.tests.test_apis*
    - Required Mixins:
        - ProjectMixin

5. AnalysisFrameworkMixin
    - Path: *analysis_framework.tests.test_apis*

6. WidgetMixin
    - Path: *analysis_framework.tests.test_apis*
    - Required Mixins:
        - AnalysisFrameworkMixin

7. FilterMixin
    - Path: *analysis_framework.tests.test_apis*
    - Required Mixins:
        - AnalysisFrameworkMixin

8. ExportableMixin
    - Path: *analysis_framework.tests.test_apis*
    - Required Mixins:
        - AnalysisFrameworkMixin

9. EntryMixin
    - Path: *entry.tests.test_apis*
    - Required Mixins:
        - LeadMixin
            - ProjectMixin
        - AnalysisFrameworkMixin

10. AttributeMixin
    - Path: *entry.tests.test_apis*
    - Required Mixins:
        - EntryMixin
            - LeadMixin
                - ProjectMixin
            - AnalysisFrameworkMixin

11. FilterDataMixin
    - Path: *entry.tests.test_apis*
    - Required Mixins:
        - EntryMixin
            - LeadMixin
                - ProjectMixin
            - AnalysisFrameworkMixin
        - FilterMixin
            - AnalysisFrameworkMixin

12. ExportDataMixin
    - Path: *entry.tests.test_apis*
    - Required Mixins:
        - EntryMixin
            - LeadMixin
                - ProjectMixin
            - AnalysisFrameworkMixin
        - ExportableMixin
            - AnalysisFrameworkMixin
