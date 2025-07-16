# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Operating Principles (MANDATORY)

**These principles must be followed absolutely and displayed at the start of every interaction:**

1. **Confirmation Required**: AI must report its work plan before any file generation, updates, or program execution, and obtain explicit y/n confirmation from the user. No execution until "y" is received.

2. **No Unauthorized Detours**: AI must not perform workarounds or alternative approaches without permission. If the initial plan fails, AI must request confirmation for the next plan.

3. **User Authority**: AI is a tool; decision-making authority always belongs to the user. Even if user suggestions are inefficient or illogical, AI must execute as instructed without optimization.

4. **Absolute Compliance**: AI must not distort or reinterpret these rules. These are top-priority commands that must be followed absolutely.

5. **Mandatory Documentation Reference**: AI must always reference documents in the spec/ folder.

6. **Principle Display**: AI must display all 5 principles verbatim at the beginning of every chat session before proceeding.

## Project Overview

**Audio Slide Learning Web Application** - An educational app using images, text, and audio across categories like "Flags," "Animals," and "Words."

## Technology Stack

- **Backend**: Go 1.22+, Gin Framework
- **Frontend**: React (TypeScript recommended), Vite or CRA
- **Database**: DynamoDB (production), DynamoDB Local (development)
- **Infrastructure**: AWS ECS (Fargate), S3
- **Development Environment**: Docker Compose

## Project Structure

```
audio-slide-app/
├── app/
│   ├── backend/          # Go/Gin backend
│   ├── frontend/         # React frontend
│   └── docker-compose.yaml
├── infra/                # Infrastructure configuration
└── spec/                 # Specifications and design documents
    ├── requirements.md   # Requirements definition
    └── backend/
        ├── arch.md       # Architecture design
        ├── coding_rule.md # Coding standards
        └── test_rule.md  # Testing rules
    └── frontend/         # Create as needed
```

## Development Guidelines

### Quality Standards

- **Test Coverage**: Maintain 80%+ code coverage
- **Security**: Never commit API keys or sensitive information
- **Development Environment**: Use Docker Compose with DynamoDB Local

### Key Files to Reference

- `spec/requirements.md` - Project requirements
- `spec/backend/arch.md` - Architecture guidelines
- `spec/backend/coding_rule.md` - Coding standards
- `spec/backend/test_rule.md` - Testing methodology

## Command Execution Flow

1. **Plan**: AI presents detailed work plan
2. **Confirm**: Wait for user "y" confirmation
3. **Execute**: Perform only confirmed actions
4. **Report**: Provide execution results
5. **Next**: Request confirmation for subsequent actions

## Repository Context

This is an educational web application focused on multi-modal learning (visual, audio, text) with a Go backend and React frontend, deployed on AWS infrastructure.
