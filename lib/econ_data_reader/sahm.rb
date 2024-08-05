require 'polars-df'
require 'csv'

module EconDataReader
  class Sahm
    attr_reader :unrate_reader

    def initialize
      @unrate_reader = EconDataReader::Fred.new('UNRATE')
    end

    def fetch(start: nil, fin: nil, interval: '1d')
      unrate = @unrate_reader.fetch(start: start, fin: fin, interval: interval)
      # Rails.logger.info { "#{__FILE__}:#{__LINE__} unrate = #{unrate.inspect}"}
      unrate['row_num'] = 1.upto(unrate.length).to_a
      unrate = unrate.set_sorted('row_num')

      # Rails.logger.info { "#{__FILE__}:#{__LINE__} unrate = #{unrate.inspect}"}
      unrate['3m rolling avg'] = unrate.rolling(index_column: "row_num", period: "3i").agg(
        [
          Polars.mean("UNRATE").alias("3m rolling avg")
        ]
      )['3m rolling avg']
      unrate['12m rolling_min'] = unrate.rolling(index_column: "row_num", period: "12i").agg(
        [
          Polars.min("UNRATE").alias("12m rolling_min")
        ]
      )['12m rolling_min']
      unrate['SAHM indicator'] = unrate['3m rolling avg'] - unrate['12m rolling_min']

      unrate = unrate.drop('3m rolling avg', 'row_num', '12m rolling_min')
      # Rails.logger.info { "#{__FILE__}:#{__LINE__} unrate = #{unrate.inspect}"}
      # unrate = unrate.drop_nulls
      unrate['SAHM recession'] = (unrate['SAHM indicator'] >= 0.5)
      # Rails.logger.info { "#{__FILE__}:#{__LINE__} unrate = #{unrate.inspect}"}
      unrate
    end
  end
end