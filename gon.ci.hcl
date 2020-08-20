source = ["./bin/mstrap"]
bundle_id = "com.maxfierke.mstrap"

apple_id {
  password = "@env:AC_PASSWORD"
}

sign {
  application_identity = "66837B7A624EA4CDB507D40C6940C74A740EF5B1"
}

zip {
  output_path = "dist/mstrap.zip"
}
