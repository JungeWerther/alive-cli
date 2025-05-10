ip=$(tofu output -json | jq -r .instance_public_ip.value)

message "Connecting to $ip"
if [ -f "$PKEY_FILE" ]; then
  success "Private key found at $PKEY_FILE"
else
  warning "Private key not found at $PKEY_FILE"
  exit 1
fi

ssh -i $PKEY_FILE ec2-user@$ip
