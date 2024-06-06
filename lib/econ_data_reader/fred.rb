class EconDataReader
  module Fred
    # Get data for the given name from the St. Louis FED (FRED).
    extend ActiveSupport::Concern

    def fred_series(symbols)
      # Read data
      # Returns
      # -------
      # data : DataFrame
      # If multiple names are passed for "series" then the index of the
      # DataFrame is the outer join of the indices of each series.
      begin
        _read(symbols)
      ensure
        close
      end
    end

    private

    def _url; "https://fred.stlouisfed.org/graph/fredgraph.csv"; end

    def _read(symbols)
      names = Array(symbols)
      urls = names.map { |n| "#{_url}?id=#{n}" }

      data_frames = urls.zip(names).map { |url, nm| _fetch_data(url, nm) }
      df = data_frames.reduce({}) { |acc, df| acc.merge(df) { |_, old_val, new_val| old_val || new_val } }
      df
    end

    def _fetch_data(url, nm)
      # Utility to fetch data
      resp = _read_url_as_StringIO(url)
      data = CSV.parse(resp, headers: true, header_converters: :symbol, converters: :all)
      data = data.map { |row| [Date.parse(row[:date]), row[nm.to_sym]] }.to_h

      begin
        data.select { |date, _| date >= start && date <= end }
      rescue KeyError => e
        if data.keys[3].to_s[7, 5] == "Error"
          raise IOError, "Failed to get the data. Check that '#{nm}' is a valid FRED series."
        else
          raise e
        end
      end
    end
  end
end
