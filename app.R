library(dotenv)

# Read in the environment variables from the .env
load_dot_env(file = ".env")

# Ensure the read values are not null
## Add string constants which equal the key of the environment variables we need
API_KEY <- Sys.getenv("API_KEY")
OUT_PATH <- Sys.getenv("OUT_PATH")

if ((API_KEY == "") || (OUT_PATH == "")) {
  print("ERROR: Environment variable(s) returned NA")
  quit(status = 1)
}

# print(paste("My API Key: ", API_KEY))
# print(paste("My output path: ", OUT_PATH))
