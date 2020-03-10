module RedmineAlertIssue
  module Hooks
    class ControllerIssuesNewAfterSave < Redmine::Hook::ViewListener
      def controller_issues_new_after_save(context={})
        issue =  context[:issue]
        issue_status = issue.status_id.to_s
        setting_status = Setting.plugin_redmine_alert_issue['issue_status']
        current_time = DateTime.now
        if issue_status == setting_status
          AlertWorker.perform_at( (issue.next_alert(current_time) ), issue.id, setting_status)
        end
      end

      def controller_issues_edit_after_save(context={})
        issue_id = context[:issue].id
        issue = Issue.find issue_id
        issue_status = issue.status.name
        setting_status = Setting.plugin_redmine_alert_issue['issue_status']
        alert = Alert.find_by(issue_id: issue_id)

        if alert && (issue_status != setting_status)
          alert.update_attributes(end_time: DateTime.now)
        end
      end
    end

    class NotificationsHookListener < Redmine::Hook::ViewListener
      render_on :view_layouts_base_html_head, :partial => "alerts/layouts_base_html_head"
    end
  end
end