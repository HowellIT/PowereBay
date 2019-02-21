Deploy Module {
    By PSGalleryModule {
        FromSource Build\Powerebay
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:PSGalleryKey
        }
    }
}