module whywait-backend

go 1.25.0

require (
	github.com/bytedance/gopkg v0.1.3
	github.com/bytedance/sonic v1.15.0
	github.com/bytedance/sonic/loader v0.5.0
	github.com/cloudwego/base64x v0.1.6
	github.com/gabriel-vasile/mimetype v1.4.12
	github.com/gin-contrib/sse v1.1.0
	github.com/gin-gonic/gin v1.12.0
	github.com/go-playground/locales v0.14.1
	github.com/go-playground/universal-translator v0.18.1
	github.com/go-playground/validator/v10 v10.30.1
	github.com/goccy/go-json v0.10.5
	github.com/goccy/go-yaml v1.19.2
	github.com/golang-jwt/jwt/v5 v5.3.1
	github.com/improbable-eng/grpc-web v0.15.0 // 👈 ADDED
	github.com/joho/godotenv v1.5.1
	github.com/json-iterator/go v1.1.12
	github.com/klauspost/compress v1.17.6
	github.com/klauspost/cpuid/v2 v2.3.0
	github.com/leodido/go-urn v1.4.0
	github.com/lib/pq v1.12.3
	github.com/mattn/go-isatty v0.0.20
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd
	github.com/modern-go/reflect2 v1.0.2
	github.com/pelletier/go-toml/v2 v2.2.4
	github.com/quic-go/qpack v0.6.0
	github.com/quic-go/quic-go v0.59.0
	github.com/rs/cors v1.11.1 // 👈 ADDED
	github.com/twitchyliquid64/golang-asm v0.15.1
	github.com/ugorji/go/codec v1.3.1
	go.mongodb.org/mongo-driver/v2 v2.5.0
	golang.org/x/arch v0.22.0
	golang.org/x/crypto v0.55.0
	golang.org/x/net v0.57.0
	golang.org/x/sys v0.47.0
	golang.org/x/text v0.41.0
	google.golang.org/genproto/googleapis/rpc v0.0.0-20260526163538-3dc84a4a5aaa
	google.golang.org/grpc v1.83.1
	google.golang.org/protobuf v1.36.12
	nhooyr.io/websocket v1.8.7
)

require github.com/desertbit/timer v1.0.1 // indirect

replace nhooyr.io/websocket => github.com/nhooyr/websocket v1.8.7

replace github.com/lyft/protoc-gen-validate => github.com/envoyproxy/protoc-gen-validate v0.6.1

replace github.com/improbable-eng/grpc-web => github.com/improbable-eng/grpc-web v0.14.0
