resource "null_resource" "mock_s3" {
  provisioner "local-exec" {
    command = "echo I am dynamo lock table!"
  }

  depends_on = []
}
