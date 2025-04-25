import os
import re
import glob

def process_template(template_path, certs_dir='certs'):
    """
    Process OpenVPN template file and substitute certificate contents.
    
    Args:
        template_path (str): Path to the template file
        certs_dir (str): Directory containing certificate files
    
    Returns:
        str: Processed template content
    """
    # Read template file
    with open(template_path, 'r') as f:
        template_content = f.read()
    
    # Find all template variables
    template_vars = re.findall(r'{{(.*?)}}', template_content)
    
    # Process each template variable
    for var in template_vars:
        cert_file = os.path.join(certs_dir, var)
        if os.path.exists(cert_file):
            with open(cert_file, 'r') as f:
                cert_content = f.read().strip()  # Trim whitespace and newlines
            # Replace template variable with certificate content
            template_content = template_content.replace(f'{{{{{var}}}}}', cert_content)
    
    return template_content

def main():
    # Create configs directory if it doesn't exist
    os.makedirs('configs', exist_ok=True)
    
    # Process all template files
    template_files = glob.glob('templates/*.template')
    for template_path in template_files:
        # Get the output filename by removing .template suffix
        output_filename = os.path.basename(template_path).replace('.template', '')
        output_path = os.path.join('configs', output_filename)
        
        # Process and save the config
        processed_content = process_template(template_path)
        with open(output_path, 'w') as f:
            f.write(processed_content)
        
        print(f"Successfully processed {template_path} and saved to {output_path}")

if __name__ == '__main__':
    main() 