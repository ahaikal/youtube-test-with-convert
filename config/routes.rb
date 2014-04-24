YoutubeTest::Application.routes.draw do
resources 'videos'
 root "videos#index"
end
