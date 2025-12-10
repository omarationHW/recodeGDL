<template>
  <div v-if="show" class="help-modal-overlay" @click.self="close">
    <div class="help-modal-container">
      <div class="help-modal-header">
        <div class="help-modal-title">
          <div class="help-icon-circle">
            <font-awesome-icon icon="book-open" />
          </div>
          <div>
            <h3>Documentación de Ayuda</h3>
            <p>{{ componentName }}</p>
          </div>
        </div>
        <button type="button" class="help-modal-close" @click="close">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <div class="help-modal-body">
        <div v-if="loading" class="help-loading">
          <div class="spinner"></div>
          <p>Cargando documentación...</p>
        </div>

        <div v-else-if="error" class="help-error">
          <font-awesome-icon icon="exclamation-triangle" />
          <strong>Documentación no disponible</strong>
          <p>{{ error }}</p>
        </div>

        <div v-else-if="sections.length" class="help-accordion">
          <div
            v-for="(section, index) in sections"
            :key="index"
            class="accordion-item"
            :class="{ 'active': activeSection === index }"
          >
            <div class="accordion-header" @click="toggleSection(index)">
              <div class="accordion-title">
                <font-awesome-icon :icon="section.iconName" />
                <span>{{ section.title }}</span>
              </div>
              <font-awesome-icon icon="chevron-down" class="accordion-arrow" />
            </div>
            <div class="accordion-content">
              <div class="accordion-body" v-html="section.content"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="help-modal-footer">
        <button type="button" class="btn-help-close" @click="close">
          <font-awesome-icon icon="times-circle" />
          Cerrar
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, watch, computed } from 'vue'

export default {
  name: 'DocumentationModal',
  props: {
    show: {
      type: Boolean,
      required: true
    },
    componentName: {
      type: String,
      required: true
    },
    moduleName: {
      type: String,
      default: 'licencias'
    }
  },
  emits: ['close'],
  setup(props, { emit }) {
    const loading = ref(false)
    const error = ref(null)
    const content = ref('')
    const activeSection = ref(0)

    const toggleSection = (index) => {
      activeSection.value = activeSection.value === index ? -1 : index
    }

    // Mapeo de iconos por tipo de sección
    const getSectionIcon = (title) => {
      const lowerTitle = title.toLowerCase()
      if (lowerTitle.includes('arquitectura') || lowerTitle.includes('general')) return 'sitemap'
      if (lowerTitle.includes('backend') || lowerTitle.includes('controlador')) return 'server'
      if (lowerTitle.includes('frontend') || lowerTitle.includes('componente')) return 'desktop'
      if (lowerTitle.includes('base de datos') || lowerTitle.includes('stored') || lowerTitle.includes('procedures')) return 'database'
      if (lowerTitle.includes('api') || lowerTitle.includes('endpoint')) return 'plug'
      if (lowerTitle.includes('migración') || lowerTitle.includes('consideraciones')) return 'exchange-alt'
      if (lowerTitle.includes('seguridad') || lowerTitle.includes('validación')) return 'shield-alt'
      if (lowerTitle.includes('extensibilidad') || lowerTitle.includes('escalabilidad')) return 'expand-arrows-alt'
      if (lowerTitle.includes('pruebas') || lowerTitle.includes('qa') || lowerTitle.includes('testing')) return 'vial'
      if (lowerTitle.includes('descripción') || lowerTitle.includes('información')) return 'info-circle'
      return 'file-alt'
    }

    // Parseador mejorado de Markdown a HTML
    const parseMarkdown = (markdown) => {
      let html = markdown

      // Code blocks (antes de otras transformaciones)
      html = html.replace(/```([a-z]*)\n([\s\S]*?)```/gim, '<pre><code class="language-$1">$2</code></pre>')
      html = html.replace(/`([^`]+)`/gim, '<code>$1</code>')

      // Headers
      html = html.replace(/^### (.*$)/gim, '<h3>$1</h3>')
      html = html.replace(/^## (.*$)/gim, '<h2>$1</h2>')
      html = html.replace(/^# (.*$)/gim, '<h1>$1</h1>')

      // Bold
      html = html.replace(/\*\*(.*?)\*\*/gim, '<strong>$1</strong>')

      // Italic
      html = html.replace(/\*(.*?)\*/gim, '<em>$1</em>')

      // Links
      html = html.replace(/\[([^\]]+)\]\(([^\)]+)\)/gim, '<a href="$2" target="_blank" rel="noopener">$1</a>')

      // Lists
      html = html.replace(/^\* (.*$)/gim, '<li>$1</li>')
      html = html.replace(/^- (.*$)/gim, '<li>$1</li>')

      // Agrupar listas
      const lines = html.split('\n')
      let inList = false
      let result = []

      for (let i = 0; i < lines.length; i++) {
        const line = lines[i]
        const isListItem = line.trim().startsWith('<li>')

        if (isListItem && !inList) {
          result.push('<ul>')
          inList = true
        } else if (!isListItem && inList) {
          result.push('</ul>')
          inList = false
        }

        result.push(line)
      }

      if (inList) result.push('</ul>')
      html = result.join('\n')

      // Horizontal rules
      html = html.replace(/^---$/gim, '<hr>')

      // Line breaks y párrafos
      html = html.replace(/\n\n+/g, '</p><p>')
      html = '<p>' + html + '</p>'

      // Clean up
      html = html.replace(/<p><h/g, '<h')
      html = html.replace(/<\/h([1-6])><\/p>/g, '</h$1>')
      html = html.replace(/<p><ul>/g, '<ul>')
      html = html.replace(/<\/ul><\/p>/g, '</ul>')
      html = html.replace(/<p><pre>/g, '<pre>')
      html = html.replace(/<\/pre><\/p>/g, '</pre>')
      html = html.replace(/<p><hr><\/p>/g, '<hr>')
      html = html.replace(/<p>\s*<\/p>/g, '')

      return html
    }

    // Dividir contenido en secciones basadas en headers ##
    const sections = computed(() => {
      if (!content.value) return []

      const lines = content.value.split('\n')
      const parsedSections = []
      let currentSection = null
      let currentContent = []

      for (const line of lines) {
        // Detectar header de nivel 2 (##)
        const h2Match = line.match(/^## (.+)$/)

        if (h2Match) {
          // Guardar sección anterior si existe
          if (currentSection) {
            parsedSections.push({
              title: currentSection,
              content: parseMarkdown(currentContent.join('\n')),
              iconName: getSectionIcon(currentSection)
            })
          }

          // Iniciar nueva sección
          currentSection = h2Match[1].trim()
          currentContent = []
        } else if (currentSection) {
          // Agregar contenido a la sección actual
          currentContent.push(line)
        }
      }

      // Guardar última sección
      if (currentSection) {
        parsedSections.push({
          title: currentSection,
          content: parseMarkdown(currentContent.join('\n')),
          iconName: getSectionIcon(currentSection)
        })
      }

      // Si no hay secciones con ##, crear una sección única
      if (parsedSections.length === 0) {
        parsedSections.push({
          title: 'Documentación',
          content: parseMarkdown(content.value),
          iconName: 'file-alt'
        })
      }

      return parsedSections
    })

    const loadDocumentation = async () => {
      if (!props.show || !props.componentName) return

      loading.value = true
      error.value = null
      content.value = ''
      activeSection.value = 0

      try {
        const possiblePaths = [
          `/docs/ayuda/${props.moduleName}/${props.componentName}.md`,
          `/docs/${props.moduleName}/${props.componentName}.md`,
          `/public/docs/ayuda/${props.moduleName}/${props.componentName}.md`,
          `/public/docs/${props.moduleName}/${props.componentName}.md`,
          `/Base/${props.moduleName}/docs/analisis/${props.componentName}.md`
        ]

        let loaded = false
        for (const docPath of possiblePaths) {
          try {
            const response = await fetch(docPath)
            if (response.ok) {
              content.value = await response.text()
              loaded = true
              break
            }
          } catch (err) {
            continue
          }
        }

        if (!loaded) {
          content.value = `# Documentación: ${props.componentName}

## Descripción
Este componente forma parte del módulo de **${props.moduleName}**.

## Información
La documentación detallada para este componente está siendo actualizada.

Por favor contacte al administrador del sistema para más información.

---

**Componente:** \`${props.componentName}.vue\`
**Módulo:** \`${props.moduleName}\``
        }
      } catch (e) {
        error.value = e.message
        console.error('Error al cargar documentación:', e)
      } finally {
        loading.value = false
      }
    }

    watch(() => props.show, (newVal) => {
      if (newVal) {
        loadDocumentation()
      }
    })

    const close = () => {
      emit('close')
    }

    return {
      loading,
      error,
      content,
      sections,
      activeSection,
      toggleSection,
      close
    }
  }
}
</script>

<style>
/* Estilos globales para FontAwesome - Asegurar que TODOS los iconos se vean */
.help-modal-overlay i[class^="fa"],
.help-modal-overlay i[class*=" fa"] {
  font-family: "Font Awesome 5 Free" !important;
  font-weight: 900 !important;
  font-style: normal !important;
  display: inline-block !important;
  text-rendering: auto !important;
  -webkit-font-smoothing: antialiased !important;
  -moz-osx-font-smoothing: grayscale !important;
}
</style>

<style scoped>

/* Overlay */
.help-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

/* Modal Container */
.help-modal-container {
  background: white;
  border-radius: 16px;
  width: 90%;
  max-width: 900px;
  max-height: 85vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.3s ease;
}

@keyframes slideUp {
  from {
    transform: translateY(50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

/* Header */
.help-modal-header {
  padding: 24px 28px;
  background: linear-gradient(135deg, #9363CD 0%, #7B4CB8 100%);
  border-radius: 16px 16px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
  box-shadow: 0 4px 12px rgba(147, 99, 205, 0.2);
}

.help-modal-title {
  display: flex;
  align-items: center;
  gap: 16px;
}

.help-icon-circle {
  width: 48px;
  height: 48px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-size: 22px;
  backdrop-filter: blur(10px);
  border: 2px solid rgba(255, 255, 255, 0.3);
}

.help-icon-circle svg {
  color: white !important;
  font-size: 22px !important;
  width: 22px !important;
  height: 22px !important;
}

.help-modal-title h3 {
  margin: 0;
  font-size: 22px;
  font-weight: 600;
  letter-spacing: -0.5px;
}

.help-modal-title p {
  margin: 4px 0 0 0;
  font-size: 13px;
  opacity: 0.9;
  font-weight: 400;
}

.help-modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  color: white;
  font-size: 18px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.help-modal-close svg {
  color: white !important;
  font-size: 18px !important;
  width: 18px !important;
  height: 18px !important;
}

.help-modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: rotate(90deg);
}

/* Body */
.help-modal-body {
  flex: 1;
  overflow-y: auto;
  padding: 24px 28px;
  background: #f8f9fa;
}

/* Loading */
.help-loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 20px;
  color: #6c757d;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e9ecef;
  border-top-color: #9363CD;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.help-loading p {
  font-size: 15px;
  margin: 0;
}

/* Error */
.help-error {
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  color: #856404;
}

.help-error svg {
  font-size: 32px !important;
  width: 32px !important;
  height: 32px !important;
  margin-bottom: 12px;
  display: block !important;
  color: #856404 !important;
}

.help-error strong {
  display: block;
  margin-bottom: 8px;
  font-size: 16px;
}

/* Accordion */
.help-accordion {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.accordion-item {
  background: white;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: all 0.3s ease;
}

.accordion-item:hover {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.accordion-header {
  padding: 18px 20px;
  background: white;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: center;
  user-select: none;
  transition: all 0.2s ease;
  border-left: 4px solid transparent;
}

.accordion-item.active .accordion-header {
  background: linear-gradient(to right, #f3eeff 0%, white 100%);
  border-left-color: #9363CD;
}

.accordion-header:hover {
  background: #f8f9fa;
}

.accordion-title {
  display: flex;
  align-items: center;
  gap: 14px;
  font-size: 16px;
  font-weight: 600;
  color: #212529;
}

.accordion-title svg {
  width: 16px !important;
  height: 16px !important;
  color: white !important;
  flex-shrink: 0;
  padding: 10px;
  background: linear-gradient(135deg, #9363CD 0%, #7B4CB8 100%);
  border-radius: 8px;
  box-sizing: content-box;
}

.accordion-arrow {
  color: #6c757d !important;
  transition: transform 0.3s ease;
  width: 14px !important;
  height: 14px !important;
}

.accordion-item.active .accordion-arrow {
  transform: rotate(180deg);
  color: #9363CD;
}

.accordion-content {
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.4s ease;
}

.accordion-item.active .accordion-content {
  max-height: 2000px;
}

.accordion-body {
  padding: 20px 24px 24px 24px;
  background: white;
  border-top: 1px solid #e9ecef;
}

/* Content Styling */
.accordion-body :deep(h1),
.accordion-body :deep(h2),
.accordion-body :deep(h3) {
  color: #212529;
  margin-top: 20px;
  margin-bottom: 12px;
  font-weight: 600;
}

.accordion-body :deep(h1) { font-size: 22px; }
.accordion-body :deep(h2) { font-size: 18px; }
.accordion-body :deep(h3) { font-size: 16px; }

.accordion-body :deep(p) {
  margin: 12px 0;
  line-height: 1.7;
  color: #495057;
  font-size: 14px;
}

.accordion-body :deep(ul) {
  margin: 12px 0;
  padding-left: 24px;
}

.accordion-body :deep(li) {
  margin: 8px 0;
  line-height: 1.6;
  color: #495057;
  font-size: 14px;
}

.accordion-body :deep(code) {
  background: #f1f3f5;
  padding: 2px 6px;
  border-radius: 4px;
  font-family: 'Consolas', 'Monaco', 'Courier New', monospace;
  font-size: 13px;
  color: #d63384;
  border: 1px solid #e9ecef;
}

.accordion-body :deep(pre) {
  background: #212529;
  color: #f8f9fa;
  padding: 16px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 16px 0;
  box-shadow: inset 0 2px 8px rgba(0, 0, 0, 0.2);
}

.accordion-body :deep(pre code) {
  background: transparent;
  padding: 0;
  border: none;
  color: #7dd3fc;
  font-size: 13px;
}

.accordion-body :deep(strong) {
  color: #212529;
  font-weight: 600;
}

.accordion-body :deep(a) {
  color: #9363CD;
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
}

.accordion-body :deep(a:hover) {
  color: #7B4CB8;
  text-decoration: underline;
}

.accordion-body :deep(hr) {
  border: none;
  border-top: 2px solid #e9ecef;
  margin: 24px 0;
}

/* Footer */
.help-modal-footer {
  padding: 20px 28px;
  background: white;
  border-top: 1px solid #e9ecef;
  border-radius: 0 0 16px 16px;
  display: flex;
  justify-content: flex-end;
}

.btn-help-close {
  background: linear-gradient(135deg, #9363CD 0%, #7B4CB8 100%);
  color: white;
  border: none;
  padding: 10px 24px;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s ease;
  box-shadow: 0 2px 8px rgba(147, 99, 205, 0.3);
}

.btn-help-close:hover {
  background: linear-gradient(135deg, #7B4CB8 0%, #6A3AA8 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(147, 99, 205, 0.5);
}

.btn-help-close svg {
  color: white !important;
  width: 14px !important;
  height: 14px !important;
}

.btn-help-close:active {
  transform: translateY(0);
}

/* Scrollbar personalizado */
.help-modal-body::-webkit-scrollbar {
  width: 8px;
}

.help-modal-body::-webkit-scrollbar-track {
  background: #f1f3f5;
}

.help-modal-body::-webkit-scrollbar-thumb {
  background: #adb5bd;
  border-radius: 4px;
}

.help-modal-body::-webkit-scrollbar-thumb:hover {
  background: #6c757d;
}

/* Responsive */
@media (max-width: 768px) {
  .help-modal-container {
    width: 95%;
    max-height: 90vh;
    border-radius: 12px;
  }

  .help-modal-header {
    padding: 20px;
  }

  .help-modal-title h3 {
    font-size: 18px;
  }

  .help-icon-circle {
    width: 40px;
    height: 40px;
    font-size: 18px;
  }

  .help-modal-body {
    padding: 16px;
  }

  .accordion-title {
    font-size: 14px;
  }

  .accordion-title svg {
    width: 14px !important;
    height: 14px !important;
    padding: 9px;
  }
}
</style>
