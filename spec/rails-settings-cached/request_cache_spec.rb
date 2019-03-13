require "spec_helper"

describe RailsSettings::RequestCache do
  let(:cache) { RailsSettings::RequestCache.current }

  it "should world" do
    Thread.new do
      expect(cache.data).to eq({})

      # write
      cache.write("foo", 123)
      expect(cache.data.key?("foo")).to eq(true)
      expect(cache.data).to eq(Thread.current[:rails_settings_request_cache])

      # read
      expect(cache.read("foo")).to eq(123)

      # delete
      cache.delete("foo")
      expect(cache.data.key?("foo")).to eq(false)
      expect(cache.read("foo")).to eq(nil)
      expect(cache.data).to eq(Thread.current[:rails_settings_request_cache])

      # write object
      cache.write("bar", age: 1, nick: "aaa")
      obj = cache.read("bar")
      expect(obj[:age]).to eq(1)
      expect(obj[:nick]).to eq("aaa")

      # fetch
      val = cache.fetch("racing-car") do
        "Mustang"
      end
      expect(val).to eq("Mustang")
      val = cache.fetch("racing-car") do
        "Mustang 5.0"
      end
      expect(val).to eq("Mustang")

      cache.clear
      expect(cache.data).to eq({})
    end
  end

  it "should thread safe" do
    # Thread safe test
    Thread.new do
      expect(cache.data).to eq({})
      expect(cache.data.key?("foo")).to eq(false)

      cache.write("foo", 234)
      cache.write("bar", "aaa")
      expect(cache.read("foo")).to eq(234)
      expect(cache.read("bar")).to eq("aaa")
    end
    Thread.new do
      expect(cache.data).to eq({})
      expect(cache.data.key?("foo")).to eq(false)

      cache.write("foo", 456)
      cache.write("bar", "bbb")
      expect(cache.read("foo")).to eq(456)
      expect(cache.read("bar")).to eq("bbb")
    end

    Thread.new do
      cache.data.clear
      expect(cache.data).to eq({})
      expect(cache.read("foo")).to eq(nil)
      expect(cache.read("bar")).to eq(nil)
    end
  end
end
