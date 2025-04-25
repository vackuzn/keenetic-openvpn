# OpenVPN Configuration Files

This repository is intended for easy configuration of Keenetic Giga (or similar) router OpenVPN.

## Requirements
- Python 3 installed
- Tested on Windows with Git Bash, but should work on Mac and Linux with minimal changes

## Repository Structure

```
.
├── certs/           # Certificate files (ignored by git)
├── configs/         # Generated configuration files (ignored by git)
├── templates/       # Configuration templates
├── process_template.py  # Template processing script
└── generate_certs.sh    # Certificate generation script
```

## Configuration Examples
See example files in the `templates` directory:
- `client.ovpn.example.template` - Client configuration template
- `server.ovpn.example.template` - Server configuration template

To make it work, configure OpenVPN public IP and private IP range in the `client.ovpn.example.template` file.

## Usage

1. Generate new certificates:
   ```bash
   ./generate_certs.sh
   ```

2. Prepare templates:
   - Edit `client.ovpn.example.template` file
   - Add public IP of OpenVPN server
   - Add private IP range of host network

3. Generate OpenVPN configurations:
   ```bash
   python process_template.py
   ```
   This will merge templates with certificates and create ready-to-use OpenVPN configs in the `configs/` directory.

## Required Certificates and Keys

Before using these configurations, you need to generate the following files in the `certs` directory:

### Server Files:
- `ca.crt` - Certificate Authority certificate
- `server.crt` - Server certificate
- `server.key` - Server private key
- `dh.pem` - Diffie-Hellman parameters
- `ta.key` - TLS authentication key

### Client Files:
- `ca.crt` - Certificate Authority certificate
- `client.crt` - Client certificate
- `client.key` - Client private key
- `ta.key` - TLS authentication key

## Step 1. Generating Certificates

The provided script will generate all required certificates:

```bash
chmod +x generate_certs.sh
./generate_certs.sh
```

The script will:
1. Create a `certs` directory
2. Generate all required certificates and keys
3. Set appropriate file permissions
4. Clean up temporary files

Note: You need OpenSSL installed on your system to run this script.

## Step 2. Configuration Generation

The repository uses a template-based approach for generating configurations:

1. Templates are stored in the `templates/` directory
2. The `process_template.py` script processes templates and substitutes certificate contents
3. Generated configurations are saved in the `configs/` directory

To generate configurations:
```bash
python process_template.py
```

This will:
1. Process all `.template` files in the `templates/` directory
2. Substitute certificate contents from the `certs/` directory
3. Save processed configurations to the `configs/` directory

## Security Notes

- Keep all private key files secure
- Use strong passwords when generating certificates
- Regularly rotate certificates and keys
- Consider using a firewall to restrict access to the OpenVPN port (1194)
- Certificate files and generated configurations are ignored by git for security reasons