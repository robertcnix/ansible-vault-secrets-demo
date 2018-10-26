playbook: vault/makana.vault secrets.yaml local.yaml remote.yaml
	ANSIBLE_LOG_PATH=playbook.log ansible-playbook --vault-password-file $(PWD)/vault/makana.vault -e @local.yaml playbook.yaml

vault/makana.vault: vault
	@echo 'super-secret-passphrase' > $@
	@chmod 400 $@

vault:
	@mkdir $@ || true
	@chmod 700 $@

local.yaml remote.yaml:
	echo 'deployment: secrets.yaml' >$@

secrets.yaml: vault/makana.vault
	echo 'THIS_IS_CLEAR: this is cleartext' >$@
	ansible-vault encrypt_string --vault-id $(PWD)/vault/makana.vault 'this is secret' --name 'THIS_SECRET' >> $@
	ansible-vault encrypt_string --vault-id $(PWD)/vault/makana.vault 'this is secret too' --name 'THAT_SECRET' >> $@
	ansible-vault encrypt_string --vault-id $(PWD)/vault/makana.vault 'this is another secret' --name 'ANOTHER_SECRET' >> $@
	echo 'THIS_IS_ALSO_CLEAR: this is also cleartext' >>secrets.yaml

clean:
	@rm -vrf vault || true
	@rm -vf secrets.yaml || true
	@rm -vf playbook.{log,retry} || true
	@echo cleaned
