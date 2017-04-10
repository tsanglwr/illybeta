json.array!(@pitch_videos) do |pitch_video|
  json.extract! pitch_video, :id, :title
  json.url pitch_video_url(pitch_video, format: :json)
end
