# frozen_string_literal: true

module GAAPI
  # A single row from a report from a query to Google Analytics.
  #
  # In addition to the methods listed, `Row` provides methods to access the
  # value of a dimension or metric by the name of the dimension or metric.
  # @!macro [new] method_missing
  #   The name is the snake case version of the Google Analytics dimension or
  #   metric name, minus the `ga:` prefix. For example, you can access the metric
  #   `ga:sessionDuration` by writing `row.session_duration`.
  #
  #   In the case of the metrics, the value returned is the appropriate Ruby type
  #   for the metric. For example, an INTEGER metric is returned as a Ruby integer.
  class Row
    # An array of the dimension values, in the order that they appear in the
    # dimension headers.
    def dimensions
      row["dimensions"] || []
    end

    def initialize(report, row)
      @report = report
      @row = row
    end

    # Define and call methods to return the value of the dimensions and metrics
    # in the report.
    # @!macro method_missing
    def method_missing(method, *args)
      if (i = dimension_method_names.find_index(method))
        define_singleton_method(method) do
          dimensions[i]
        end
        send(method)
      elsif (i = metric_method_names.find_index(method))
        define_singleton_method(method) do
          convert_metric(i)
        end
        send(method)
      else
        super
      end
    end

    # An array of the metric values, in the order that they appear in the
    # metric headers. These are the raw values as returned by the Google Analytics
    # query, in other words, they're strings.
    def metrics
      # NOTE: There is one entry in the `row["metrics"]` array for each date range.
      # Since currently we only support one date range, this following index is
      # always 0.
      row["metrics"][0]["values"]
    end

    def respond_to_missing?
      true
    end

    # Return the data from the row as an Array, ordered by:
    # - Headers first, in the order that they appear in the Report#headers array.
    # - Metrics next, in the order that they appear in the Report#metrics array.
    def to_a
      dimensions + metrics
    end

    private

    attr_reader :report, :row

    # Convert metric to the right type.
    def convert_metric(i)
      case report.metric_type(i)
      when "INTEGER"
        # INTEGER  Integer metric.
        metrics[i].to_i
      when "FLOAT", "PERCENT"
        # FLOAT  Float metric.
        # PERCENT  Percentage metric.
        metrics[i].to_f
      when "CURRENCY"
        # CURRENCY  Currency metric.
        # TODO: Do this better.
        metrics[i].to_f
      when "TIME"
        # Google documentation claims to following:
        # TIME  Time metric in HH:MM:SS format.
        # It also says it's seconds, and that's what I see in real results.
        # So comment out the following:
        # (metrics[i][0..1].to_i +
        #   metrics[i][3..4].to_i * 60 +
        #   metrics[i][6..7].to_i * 24 * 60)
        # Simply make it a float.
        metrics[i].to_f
      else
        # METRIC_TYPE_UNSPECIFIED  Metric type is unspecified.
        metric[i]
      end
    end

    # Return the dimensions in the response, as method names.
    def dimension_method_names
      report.dimensions.map { |d| ga_to_method_name(d) }
    end

    # Change a dimension or metric name to a method name.
    # Strip off the "ga:" at the beginning, change it to snake case, and
    # convert it to a symbol.
    def ga_to_method_name(name)
      snakecase(name.gsub(/\Aga:/, "")).to_sym
    end

    # Return the metrics in the response, as method names.
    def metric_method_names
      report.metrics.map { |d| ga_to_method_name(d) }
    end

    # From: https://stackoverflow.com/a/37381260/3109926
    def snakecase(string)
      string.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr("-", "_")
            .gsub(/\s/, "_")
            .gsub(/__+/, "_")
            .downcase
    end
  end
end
