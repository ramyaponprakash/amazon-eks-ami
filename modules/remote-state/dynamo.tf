resource "null_resource" "mock_dynano" {
  provisioner "local-exec" {
    command = "echo I am dynamo lock table!"
  }
}
