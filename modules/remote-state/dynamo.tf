resource "null_resource" "mock_dynano" {
  provisioner "local-exec" {
    command = "echo I am dynamo lock table!"
  }

  depends_on = [
    null_resource.mock_s3
  ]
}
