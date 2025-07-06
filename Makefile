ENV_FILE := .env

# Проверка наличия .env
check-env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "$(ENV_FILE) отсутствует. Копирую из .env.example"; \
		cp .env.example $(ENV_FILE); \
	else \
		echo "$(ENV_FILE) найден."; \
	fi

# Проверка и установка NVIDIA Container Toolkit
check-nvidia:
	@if ! command -v nvidia-container-toolkit >/dev/null 2>&1; then \
		echo "NVIDIA Container Toolkit не найден. Устанавливаю"; \
		distribution=$$(. /etc/os-release; echo $$ID$$VERSION_ID) && \
		curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
		curl -s -L https://nvidia.github.io/libnvidia-container/$$distribution/libnvidia-container.list | \
		sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#' | \
		sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null && \
		sudo apt-get update && \
		sudo apt-get install -y nvidia-container-toolkit && \
		sudo systemctl restart docker; \
	else \
		echo "NVIDIA Container Toolkit уже установлен."; \
	fi

# Основной запуск
up: check-env check-nvidia
	docker compose --profile gpu up -d

# Остановка
down:
	docker compose --profile gpu down