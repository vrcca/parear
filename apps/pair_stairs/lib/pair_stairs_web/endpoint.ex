defmodule PairStairsWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :pair_stairs

  socket "/socket", PairStairsWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :pair_stairs,
    gzip: false,
    only:
      ~w(css fonts images js favicon.ico android-chrome-192x192.png android-chrome-512x512.png apple-touch-icon.png browserconfig.xml favicon-16x16.png favicon-32x32.png favicon.ico html_code.html mstile-144x144.png mstile-150x150.png mstile-310x150.png mstile-310x310.png mstile-70x70.png safari-pinned-tab.svg site.webmanifest robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_pair_stairs_key",
    signing_salt: "VbAexRRf"

  plug PairStairsWeb.Router
end
