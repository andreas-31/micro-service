FROM python:3.7.3-stretch

## Step 1:
# Create a working directory
WORKDIR /app

## Step 2:
# Copy source code to working directory
COPY the_app  /app/

## Step 3:
# Install packages from requirements.txt
# hadolint ignore=DL3013
RUN pip3 install --upgrade pip &&\
    pip3 install --trusted-host pypi.python.org -r requirements.txt

## Step 4:
# Expose port 80
EXPOSE 8501

## Step 5:
# Run app.py at container launch
CMD ["sh", "setup.sh"]
CMD ["streamlit", "run", "app.py"]
