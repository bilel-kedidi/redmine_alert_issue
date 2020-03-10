require_dependency 'issue'

module RedmineAlertIssue
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        has_many :alerts
      end
    end

    module InstanceMethods
      def next_alert(current_time)
        current_day = current_time.day
        current_month = current_time.month
        current_year = current_time.year
        current_wday = current_time.wday
        current_zone = current_time.zone

        finish_work_time = DateTime.new(current_year, current_month, current_day, 18, 0, 0)
        finish_work_time = finish_work_time.change(offset: current_zone)

        add_hours = 2
        next_time = current_time + 2.hours
        if (next_time > finish_work_time) && ((1...5).include? current_wday)
          add_hours = add_hours + 14
        elsif (next_time > finish_work_time) && (current_wday == 5)
          add_hours = add_hours + 14 + 48
        end
        (current_time + add_hours.hours)
      end
    end
  end
end

Issue.send(:include, RedmineAlertIssue::IssuePatch)
