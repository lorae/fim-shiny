library(dotenv)

# Read in the environment variables from the .env
load_dot_env(file = ".env")

# Ensure the read values are not null
## Add string constants which equal the key of the environment variables we need
FRED_API_KEY <- Sys.getenv("FRED_API_KEY")
WD_PATH <- Sys.getenv("WD_PATH")
HAVER_PATH <- Sys.getenv("HAVER_PATH")

if ((FRED_API_KEY == "") || (WD_PATH == "") || (HAVER_PATH == "")) {
  print("ERROR: Environment variable(s) returned NA")
  quit(status = 1)
}

print(paste("My FRED API Key: ", FRED_API_KEY))
print(paste("My output path: ", WD_PATH))
print(paste("My Haver path: ", HAVER_PATH))
