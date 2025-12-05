<template>
  <aside
    class="app-sidebar"
    :class="{ 'sidebar-collapsed': sidebarCollapsed }"
    :style="{ width: sidebarWidth + 'px' }"
  >
    <!-- Handle de redimensionamiento -->
    <div
      class="sidebar-resize-handle"
      @mousedown="startResize"
      title="Arrastra para ajustar el ancho"
    ></div>

    <!-- Búsqueda en menú -->
    <div class="sidebar-search">
      <div class="search-input-wrapper">
        <font-awesome-icon icon="search" class="search-icon" />
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Buscar en menú..."
          class="search-input"
          @input="handleSearch"
        />
        <button
          v-if="searchQuery"
          @click="clearSearch"
          class="search-clear"
          title="Limpiar búsqueda"
        >
          <font-awesome-icon icon="times" />
        </button>
      </div>
      <div v-if="searchQuery && filteredItems.length === 0" class="search-no-results">
        <font-awesome-icon icon="inbox" />
        <span>No se encontraron resultados</span>
      </div>
    </div>

    <nav class="sidebar-nav">
      <ul class="nav-list">
        <MenuItem
          v-for="item in filteredItems"
          :key="item.path || item.label"
          :item="item"
          :level="0"
          :search-query="searchQuery"
        />
      </ul>
    </nav>
  </aside>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import MenuItem from './MenuItem.vue'
import { useSidebar } from '@/composables/useSidebar'

const { sidebarCollapsed, sidebarWidth, setSidebarWidth } = useSidebar()
const searchQuery = ref('')

// Redimensionamiento del sidebar
const MIN_WIDTH = 200
const MAX_WIDTH = 500
const DEFAULT_WIDTH = 280

const isResizing = ref(false)
const mutationObserver = ref(null)

// Cargar ancho guardado desde localStorage y configurar observador
onMounted(() => {
  const savedWidth = localStorage.getItem('sidebarWidth')
  if (savedWidth) {
    const width = parseInt(savedWidth)
    if (width >= MIN_WIDTH && width <= MAX_WIDTH) {
      setSidebarWidth(width)
    }
  }

  // Auto-ajustar después de montar (dar tiempo al DOM para renderizar)
  setTimeout(() => {
    autoAdjustWidth()
    setupMutationObserver()
  }, 500)
})

// Auto-ajustar cuando cambie el contenido visible por búsqueda
watch(searchQuery, () => {
  setTimeout(() => {
    autoAdjustWidth()
  }, 300)
})

// Configurar observador de mutaciones para detectar expansión/colapso de nodos
const setupMutationObserver = () => {
  const sidebar = document.querySelector('.app-sidebar')
  if (!sidebar) return

  // Crear observador que detecte cambios en clases y atributos
  mutationObserver.value = new MutationObserver((mutations) => {
    let shouldAdjust = false

    mutations.forEach((mutation) => {
      // Detectar cambios en clases (expanded/collapsed)
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        const target = mutation.target
        // Verificar si es un nav-item que cambió su estado de expansión
        if (target.classList.contains('nav-item') ||
            target.classList.contains('nav-parent-link') ||
            target.classList.contains('expanded')) {
          shouldAdjust = true
        }
      }

      // Detectar cambios en estructura (elementos añadidos/removidos)
      if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
        shouldAdjust = true
      }
    })

    // Auto-ajustar si detectamos cambios relevantes
    if (shouldAdjust && !isResizing.value) {
      setTimeout(() => {
        autoAdjustWidth()
      }, 150)
    }
  })

  // Observar cambios en todo el sidebar
  mutationObserver.value.observe(sidebar, {
    attributes: true,
    attributeFilter: ['class', 'style'],
    childList: true,
    subtree: true
  })
}

// Verificar si un elemento es realmente visible (considerando nodos padre colapsados)
const isElementTrulyVisible = (element) => {
  // Verificar si el elemento está dentro de un ul.nav-submenu oculto
  let current = element
  while (current && current !== document.body) {
    // Si es un ul.nav-submenu, verificar su display
    if (current.tagName === 'UL' && current.classList.contains('nav-submenu')) {
      const styles = window.getComputedStyle(current)
      // Si tiene display:none, el elemento NO es visible
      if (styles.display === 'none') {
        return false
      }
    }

    current = current.parentElement
  }

  // Verificar offsetParent como último recurso
  return element.offsetParent !== null
}

// Medir el ancho real del texto usando un elemento temporal
const measureTextWidth = (text, element) => {
  // Crear un span temporal para medir el texto
  const tempSpan = document.createElement('span')
  tempSpan.style.visibility = 'hidden'
  tempSpan.style.position = 'absolute'
  tempSpan.style.whiteSpace = 'nowrap'
  tempSpan.style.fontSize = window.getComputedStyle(element).fontSize
  tempSpan.style.fontFamily = window.getComputedStyle(element).fontFamily
  tempSpan.style.fontWeight = window.getComputedStyle(element).fontWeight
  tempSpan.textContent = text

  document.body.appendChild(tempSpan)
  const width = tempSpan.offsetWidth
  document.body.removeChild(tempSpan)

  return width
}

// Función para auto-ajustar el ancho al contenido más largo VISIBLE
const autoAdjustWidth = () => {
  // No ajustar si el usuario está redimensionando manualmente
  if (isResizing.value) return

  // Esperar siguiente tick para que el DOM esté actualizado
  setTimeout(() => {
    const sidebar = document.querySelector('.app-sidebar')
    if (!sidebar) return

    // Encontrar todos los elementos de texto en el menú
    const navLinks = sidebar.querySelectorAll('.nav-link')
    let maxWidth = MIN_WIDTH
    let visibleCount = 0
    let longestText = ''

    navLinks.forEach(link => {
      // Solo considerar elementos REALMENTE visibles
      if (!isElementTrulyVisible(link)) return

      visibleCount++
      const textElement = link.querySelector('.nav-text')
      if (!textElement) return

      // Obtener el texto limpio (sin HTML)
      const text = textElement.textContent.trim()

      // Medir el ancho REAL del texto usando elemento temporal
      const textWidth = measureTextWidth(text, textElement)

      // Calcular nivel de indentación
      let indentLevel = 0
      let parent = link.closest('.nav-item')
      while (parent) {
        const parentItem = parent.parentElement?.closest('.nav-item')
        if (parentItem) {
          indentLevel++
          parent = parentItem
        } else {
          break
        }
      }

      // Calcular ancho total necesario:
      // - Padding base: 24px (0.75rem × 2)
      // - Icono: 24px
      // - Gap: 12px
      // - Texto: medido independientemente
      // - Chevron (si tiene hijos): 24px
      // - Indentación: nivel × 20px
      const basePadding = 24
      const iconWidth = 24
      const gapWidth = 12
      const chevronWidth = link.querySelector('.nav-chevron') ? 24 : 0
      const indentWidth = indentLevel * 20

      const totalWidth = basePadding + iconWidth + gapWidth + textWidth + chevronWidth + indentWidth

      if (totalWidth > maxWidth) {
        maxWidth = totalWidth
        longestText = text
      }
    })

    // Agregar margen de seguridad de 60px (suficiente para scrollbar y padding extra)
    maxWidth += 60

    // Respetar límites
    if (maxWidth < MIN_WIDTH) maxWidth = MIN_WIDTH
    if (maxWidth > MAX_WIDTH) maxWidth = MAX_WIDTH

    // IMPORTANTE: Aplicar el ancho calculado SIEMPRE (permitir crecer Y decrecer)
    const newWidth = Math.round(maxWidth)

    // Solo actualizar si hay diferencia significativa (más de 5px) para evitar ajustes constantes
    if (Math.abs(sidebarWidth.value - newWidth) > 5) {
      setSidebarWidth(newWidth)
      localStorage.setItem('sidebarWidth', newWidth.toString())
    }
  }, 100)
}

// Iniciar redimensionamiento
const startResize = (e) => {
  isResizing.value = true
  document.body.style.cursor = 'ew-resize'
  document.body.style.userSelect = 'none'

  document.addEventListener('mousemove', handleResize)
  document.addEventListener('mouseup', stopResize)
}

// Manejar redimensionamiento
const handleResize = (e) => {
  if (!isResizing.value) return

  const newWidth = e.clientX

  if (newWidth >= MIN_WIDTH && newWidth <= MAX_WIDTH) {
    setSidebarWidth(newWidth)
  }
}

// Detener redimensionamiento
const stopResize = () => {
  if (isResizing.value) {
    isResizing.value = false
    document.body.style.cursor = ''
    document.body.style.userSelect = ''

    // Guardar ancho en localStorage
    localStorage.setItem('sidebarWidth', sidebarWidth.value.toString())

    document.removeEventListener('mousemove', handleResize)
    document.removeEventListener('mouseup', stopResize)
  }
}

// Limpiar listeners y observer al desmontar
onUnmounted(() => {
  document.removeEventListener('mousemove', handleResize)
  document.removeEventListener('mouseup', stopResize)

  // Desconectar mutation observer
  if (mutationObserver.value) {
    mutationObserver.value.disconnect()
  }
})

const menuItems = [
  {
    path: '/',
    label: 'Dashboard',
    icon: 'home'
  },
  {
    label: 'Módulos Administrativos',
    icon: 'folder',
    expanded: true,
    children: [
      {
        label: 'Estacionamientos',
        icon: 'square-parking',
        children: [
          {
            label: 'Públicos',
            icon: 'parking',
            children: [
              { path: '/estacionamiento-publico', label: 'Menú' },
              { path: '/estacionamiento-publico/consulta', label: 'Consulta' },
              { path: '/estacionamiento-publico/transacciones', label: 'Transacciones' },
              { path: '/estacionamiento-publico/actualizacion', label: 'Actualización' },
              { path: '/estacionamiento-publico/nuevo', label: 'Nuevo' },
              { path: '/estacionamiento-publico/reportes', label: 'Reportes' },
              { path: '/estacionamiento-publico/accesos', label: 'Accesos' },
              { path: '/estacionamiento-publico/bajas', label: 'Bajas' },
              { path: '/estacionamiento-publico/generar', label: 'Generar' },
              { path: '/estacionamiento-publico/pagos', label: 'Pagos' },
              { path: '/estacionamiento-publico/info', label: 'Información' },
              { path: '/estacionamiento-publico/listados', label: 'Listados' },
              { path: '/estacionamiento-publico/estadisticas', label: 'Estadísticas' },
              { path: '/estacionamiento-publico/conciliacion', label: 'Conciliación Banorte' }
              ,
              { path: '/estacionamiento-publico/edocta', label: 'Estado de Cuenta' },
              { path: '/estacionamiento-publico/reporte-lista', label: 'Listado (opc)' }
              ,
              { path: '/estacionamiento-publico/reporte-pagos', label: 'Reporte de Pagos' },
              { path: '/estacionamiento-publico/reporte-folios', label: 'Reporte de Folios' },
              { path: '/estacionamiento-publico/estado-mpio', label: 'Estado Municipal' },
              { path: '/estacionamiento-publico/trans-folios', label: 'Transferencia Folios' },
              { path: '/estacionamiento-publico/up-pagos', label: 'Actualizar Pagos' },
              { path: '/estacionamiento-publico/valet-paso', label: 'Valet Paso' }
              ,
              { path: '/estacionamiento-publico/passwords', label: 'Usuarios/Passwords' },
              { path: '/estacionamiento-publico/gen-arc-altas', label: 'Gen. Remesa Altas' },
              { path: '/estacionamiento-publico/gen-arc-diario', label: 'Gen. Diario' },
              { path: '/estacionamiento-publico/gen-individual', label: 'Gen. Individual' },
              { path: '/estacionamiento-publico/gen-pgos-banorte', label: 'Gen. Pagos Banorte' },
              { path: '/estacionamiento-publico/reactiva-folios', label: 'Reactivar Folios' },
              { path: '/estacionamiento-publico/cons-gral', label: 'Consulta General' },
              { path: '/estacionamiento-publico/cons-remesas', label: 'Consulta Remesas' }
              ,
              { path: '/estacionamiento-publico/aplica-pago-divadmin', label: 'Aplicar Pago (DivAdmin)' },
              { path: '/estacionamiento-publico/relacion-folios', label: 'Relación de Folios' },
              { path: '/estacionamiento-publico/imp-padron', label: 'Imprimir Padrón' },
              { path: '/estacionamiento-publico/metrometers', label: 'Metrometers' },
              { path: '/estacionamiento-publico/aspecto', label: 'Aspecto' },
              { path: '/estacionamiento-publico/autoriz-descto', label: 'Autoriz. Descuento' },
              { path: '/estacionamiento-publico/contrarecibos', label: 'Contrarecibos' },
              { path: '/estacionamiento-publico/mensaje', label: 'Mensaje' }
              ,
              { path: '/estacionamiento-publico/folios-alta', label: 'Alta de Folios' },
              { path: '/estacionamiento-publico/carga-edoex', label: 'Carga Estado/Externos' },
              { path: '/estacionamiento-publico/predio-carto', label: 'Predio Carto' }
              ,
              { path: '/estacionamiento-publico/reportes-calco', label: 'Reportes Calco' },
              { path: '/estacionamiento-publico/solic-rep-folios', label: 'Solic. Rep. Folios' }
              ,
              { path: '/estacionamiento-publico/seguridad-login', label: 'Seguridad (Login)' },
              { path: '/estacionamiento-publico/inspectores', label: 'Inspectores' }
              ,
              { path: '/estacionamiento-publico/baja-multiple', label: 'Baja Múltiple' }
            ]
          },
          {
            label: 'Exclusivos',
            icon: 'car',
            children: [
              { path: '/estacionamiento-exclusivo', label: 'Menú' },
              { path: '/estacionamiento-exclusivo/acceso', label: 'Acceso' },
              { path: '/estacionamiento-exclusivo/individual', label: 'Individual' },
              { path: '/estacionamiento-exclusivo/individual-folio', label: 'Individual por Folio' },
              { path: '/estacionamiento-exclusivo/consulta-reg', label: 'Consulta por Registro' },
              { path: '/estacionamiento-exclusivo/cons-his', label: 'Consulta Histórica' },
              { path: '/estacionamiento-exclusivo/listados', label: 'Listados' },
              { path: '/estacionamiento-exclusivo/listados-ade', label: 'Listados con Adeudos' },
              { path: '/estacionamiento-exclusivo/listados-sin-adereq', label: 'Listados sin Adeudos/Req' },
              { path: '/estacionamiento-exclusivo/listx-reg', label: 'Lista por Registro' },
              { path: '/estacionamiento-exclusivo/listx-fec', label: 'Lista por Fecha' },
              { path: '/estacionamiento-exclusivo/estdx-folio', label: 'Estado por Folio' },
              { path: '/estacionamiento-exclusivo/modificar', label: 'Modificar' },
              { path: '/estacionamiento-exclusivo/modificar-bien', label: 'Modificar Bien' },
              { path: '/estacionamiento-exclusivo/modif-masiva', label: 'Modificación Masiva' },
              { path: '/estacionamiento-exclusivo/facturacion', label: 'Facturación' },
              { path: '/estacionamiento-exclusivo/requerimientos', label: 'Requerimientos' },
              { path: '/estacionamiento-exclusivo/recuperacion', label: 'Recuperación' },
              { path: '/estacionamiento-exclusivo/notificaciones', label: 'Notificaciones' },
              { path: '/estacionamiento-exclusivo/notificaciones-mes', label: 'Notificaciones por Mes' },
              { path: '/estacionamiento-exclusivo/prenomina', label: 'Prenómina' },
              { path: '/estacionamiento-exclusivo/reasignacion', label: 'Reasignación' },
              { path: '/estacionamiento-exclusivo/ejecutores', label: 'Ejecutores' },
              { path: '/estacionamiento-exclusivo/abc-ejec', label: 'ABC Ejecutores' },
              { path: '/estacionamiento-exclusivo/lista-ejec', label: 'Lista de Ejecutores' },
              { path: '/estacionamiento-exclusivo/list-eje', label: 'Listado Ejecutores' },
              { path: '/estacionamiento-exclusivo/lista-gastos-cob', label: 'Lista Gastos de Cobranza' },
              { path: '/estacionamiento-exclusivo/autoriza-des', label: 'Autorizar Descuento' },
              { path: '/estacionamiento-exclusivo/carta-invitacion', label: 'Carta Invitación' },
              { path: '/estacionamiento-exclusivo/cmult-emision', label: 'Emisión Múltiple' },
              { path: '/estacionamiento-exclusivo/cmult-folio', label: 'Múltiple por Folio' },
              { path: '/estacionamiento-exclusivo/exportar-excel', label: 'Exportar a Excel' },
              { path: '/estacionamiento-exclusivo/firma-electronica', label: 'Firma Electrónica' },
              { path: '/estacionamiento-exclusivo/apremios-svn-expedientes', label: 'Apremios SVN - Expedientes' },
              { path: '/estacionamiento-exclusivo/apremios-svn-fases', label: 'Apremios SVN - Fases' },
              { path: '/estacionamiento-exclusivo/apremios-svn-actuaciones', label: 'Apremios SVN - Actuaciones' },
              { path: '/estacionamiento-exclusivo/apremios-svn-notificaciones', label: 'Apremios SVN - Notificaciones' },
              { path: '/estacionamiento-exclusivo/apremios-svn-pagos', label: 'Apremios SVN - Pagos' },
              { path: '/estacionamiento-exclusivo/apremios-svn-reportes', label: 'Apremios SVN - Reportes' },
              { path: '/estacionamiento-exclusivo/sfrm-chgpass', label: 'Cambio de Contraseña' }
            ]
          }
        ]
      },
      {
        label: 'Aseo Contratado',
        icon: 'broom',
        children: [
          {
            path: '/aseo-contratado/empresas',
            label: 'ABC Empresas',
            icon: 'building'
          },
          {
            path: '/aseo-contratado/tipos-aseo',
            label: 'ABC Tipos de Aseo',
            icon: 'list-check'
          },
          {
            path: '/aseo-contratado/zonas',
            label: 'ABC Zonas',
            icon: 'map-marked-alt'
          },
          {
            path: '/aseo-contratado/unidades-recoleccion',
            label: 'ABC Unidades de Recolección',
            icon: 'truck'
          },
          {
            path: '/aseo-contratado/recaudadoras',
            label: 'ABC Recaudadoras',
            icon: 'money-check-alt'
          },
          {
            path: '/aseo-contratado/claves-operacion',
            label: 'ABC Claves de Operación',
            icon: 'key'
          },
          {
            path: '/aseo-contratado/gastos',
            label: 'ABC Gastos',
            icon: 'receipt'
          },
          {
            path: '/aseo-contratado/recargos',
            label: 'ABC Recargos',
            icon: 'percent'
          },
          {
            path: '/aseo-contratado/tipos-empresa',
            label: 'ABC Tipos de Empresa',
            icon: 'building-user'
          },
          {
            path: '/aseo-contratado/adeudos',
            label: 'Gestión de Adeudos',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/aseo-contratado/adeudos-carga',
            label: 'Carga Masiva de Adeudos',
            icon: 'upload'
          },
          {
            path: '/aseo-contratado/adeudos-nvo',
            label: 'Generar Adeudos',
            icon: 'file-invoice'
          },
          {
            path: '/aseo-contratado/adeudos-ins',
            label: 'Insertar Adeudos',
            icon: 'plus-circle'
          },
          {
            path: '/aseo-contratado/adeudos-pag',
            label: 'Registro de Pagos',
            icon: 'dollar-sign'
          },
          {
            path: '/aseo-contratado/adeudos-edocta',
            label: 'Estado de Cuenta',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/aseo-contratado/contratos-consulta',
            label: 'Consulta de Contratos',
            icon: 'file-contract'
          },
          {
            path: '/aseo-contratado/contratos-alta',
            label: 'Alta de Contratos',
            icon: 'file-circle-plus'
          },
          {
            path: '/aseo-contratado/contratos-mod',
            label: 'Modificación de Contratos',
            icon: 'file-pen'
          },
          {
            path: '/aseo-contratado/contratos-baja',
            label: 'Baja de Contratos',
            icon: 'file-excel'
          },
          {
            path: '/aseo-contratado/actcont-cr',
            label: 'Actualización Masiva',
            icon: 'sync-alt'
          },
          {
            path: '/aseo-contratado/rpt-adeudos',
            label: 'Reporte de Adeudos',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/aseo-contratado/rpt-pagos',
            label: 'Reporte de Pagos',
            icon: 'money-check-dollar'
          },
          {
            path: '/aseo-contratado/rpt-estado-cuenta',
            label: 'Estado de Cuenta',
            icon: 'file-invoice'
          },
          {
            path: '/aseo-contratado/rpt-contratos',
            label: 'Reporte de Contratos',
            icon: 'file-contract'
          },
          {
            path: '/aseo-contratado/rpt-empresas',
            label: 'Reporte de Empresas',
            icon: 'building'
          },
          {
            path: '/aseo-contratado/adeudos-est',
            label: 'Consulta de Estatus',
            icon: 'chart-line'
          },
          {
            path: '/aseo-contratado/adeudos-mult-ins',
            label: 'Inserción Masiva',
            icon: 'layer-group'
          },
          {
            path: '/aseo-contratado/adeudos-exe-del',
            label: 'Eliminación por Ejecución',
            icon: 'trash-can'
          },
          {
            path: '/aseo-contratado/adeudos-cn-cond',
            label: 'Adeudos Condonados',
            icon: 'hand-holding-dollar'
          },
          {
            path: '/aseo-contratado/adeudos-opc-mult',
            label: 'Opciones Múltiples',
            icon: 'sliders'
          },
          // LOTE 7: Operaciones Especiales y Convenios
          {
            path: '/aseo-contratado/aplica-multas',
            label: 'Aplicación de Multas',
            icon: 'gavel'
          },
          {
            path: '/aseo-contratado/datos-convenio',
            label: 'Convenios de Pago',
            icon: 'file-contract'
          },
          {
            path: '/aseo-contratado/descuentos-pago',
            label: 'Descuentos por Pago',
            icon: 'percent'
          },
          {
            path: '/aseo-contratado/ejercicios-gestion',
            label: 'Ejercicios Fiscales',
            icon: 'calendar-days'
          },
          {
            path: '/aseo-contratado/relacion-contratos',
            label: 'Relación de Contratos',
            icon: 'link'
          },
          // LOTE 8: Pagos y Consultas Avanzadas
          {
            path: '/aseo-contratado/adeudos-pag-mult',
            label: 'Pago Múltiple de Adeudos',
            icon: 'money-bill-wave'
          },
          {
            path: '/aseo-contratado/adeudos-venc',
            label: 'Adeudos Vencidos',
            icon: 'calendar-xmark'
          },
          {
            path: '/aseo-contratado/contratos-adeudos',
            label: 'Adeudos por Contrato',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/aseo-contratado/pagos-cons-cont',
            label: 'Consulta de Pagos',
            icon: 'receipt'
          },
          {
            path: '/aseo-contratado/empresas-contratos',
            label: 'Contratos por Empresa',
            icon: 'building'
          },
          // LOTE 9: Adeudos y Pagos Adicionales
          {
            path: '/aseo-contratado/adeudos-pag-upd-per',
            label: 'Actualizar Periodos de Pagos',
            icon: 'calendar-check'
          },
          {
            path: '/aseo-contratado/adeudos-upd-exed',
            label: 'Adeudos Exentos',
            icon: 'shield-halved'
          },
          {
            path: '/aseo-contratado/pagos-con-fpgo',
            label: 'Pagos por Forma de Pago',
            icon: 'credit-card'
          },
          {
            path: '/aseo-contratado/pagos-cons-cont-asc',
            label: 'Consulta Ascendente de Pagos',
            icon: 'arrow-up-wide-short'
          },
          {
            path: '/aseo-contratado/contratos-cancela',
            label: 'Cancelación de Contratos',
            icon: 'ban'
          },
          // LOTE 10: Consultas y Reportes Adicionales
          {
            path: '/aseo-contratado/contratos-cons-admin',
            label: 'Consulta Administrativa',
            icon: 'clipboard-list'
          },
          {
            path: '/aseo-contratado/contratos-cons-dom',
            label: 'Contratos Domésticos',
            icon: 'home'
          },
          {
            path: '/aseo-contratado/rep-padron-contratos',
            label: 'Padrón de Contratos',
            icon: 'file-lines'
          },
          {
            path: '/aseo-contratado/rep-recaudadoras',
            label: 'Reporte de Recaudadoras',
            icon: 'building-columns'
          },
          {
            path: '/aseo-contratado/rep-tipos-aseo',
            label: 'Reporte por Tipos de Aseo',
            icon: 'chart-pie'
          },
          // LOTE 11: Actualizaciones y Estadísticas
          {
            path: '/aseo-contratado/contratos-upd-periodo',
            label: 'Actualizar Periodos',
            icon: 'calendar-days'
          },
          {
            path: '/aseo-contratado/contratos-upd-und',
            label: 'Actualizar Unidades',
            icon: 'truck'
          },
          {
            path: '/aseo-contratado/contratos-est',
            label: 'Estadísticas de Contratos',
            icon: 'chart-line'
          },
          {
            path: '/aseo-contratado/contratos-estgral',
            label: 'Estadísticas Generales',
            icon: 'chart-pie'
          },
          {
            path: '/aseo-contratado/rep-adeud-cond',
            label: 'Adeudos Condonados',
            icon: 'hand-holding-dollar'
          },
          // LOTE 12: Consultas y Actualizaciones Adicionales
          {
            path: '/aseo-contratado/cons-cont',
            label: 'Consulta de Contratos',
            icon: 'search'
          },
          {
            path: '/aseo-contratado/cons-cont-asc',
            label: 'Consulta Ordenada',
            icon: 'arrows-up-down'
          },
          {
            path: '/aseo-contratado/upd-01',
            label: 'Actualización General',
            icon: 'wrench'
          },
          {
            path: '/aseo-contratado/upd-ini-obl',
            label: 'Inicialización de Obligaciones',
            icon: 'calendar-check'
          },
          {
            path: '/aseo-contratado/rep-zonas',
            label: 'Reporte por Zonas',
            icon: 'map-marked-alt'
          },
          // LOTE 13 FINAL: Componentes Finales del Módulo
          {
            path: '/aseo-contratado/contratos',
            label: 'ABM Contratos',
            icon: 'file-contract'
          },
          {
            path: '/aseo-contratado/ins-b',
            label: 'Inscripción Rápida',
            icon: 'file-import'
          },
          {
            path: '/aseo-contratado/updxcont',
            label: 'Actualización Individual',
            icon: 'edit'
          },
          {
            path: '/aseo-contratado/upd-undc',
            label: 'Actualizar por Colonia',
            icon: 'truck-moving'
          },
          {
            path: '/aseo-contratado/estgral2',
            label: 'Estadísticas Avanzadas',
            icon: 'chart-bar'
          },
          {
            path: '/aseo-contratado/ctrol-imp-cat',
            label: 'Control Importación Catastral',
            icon: 'file-import'
          }
        ]
      },
      {
        label: 'Cementerios',
        icon: 'cross',
        children: [
          {
            path: '/cementerios/abcementer',
            label: 'Catálogo de Cementerios',
            icon: 'cross'
          },
          {
            path: '/cementerios/titulos',
            label: 'Gestión de Títulos',
            icon: 'file-contract'
          },
          {
            path: '/cementerios/consultafol',
            label: 'Consulta de Folio',
            icon: 'search'
          },
          {
            path: '/cementerios/abcpagos',
            label: 'Registro de Pagos',
            icon: 'money-bill-wave'
          },
          {
            path: '/cementerios/liquidaciones',
            label: 'Liquidaciones',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/cementerios/abcfolio',
            label: 'ABC de Folios',
            icon: 'folder-open'
          },
          {
            path: '/cementerios/bonificaciones',
            label: 'Bonificaciones',
            icon: 'hand-holding-usd'
          },
          {
            path: '/cementerios/descuentos',
            label: 'Descuentos',
            icon: 'percentage'
          },
          {
            path: '/cementerios/abcrecargos',
            label: 'ABC de Recargos',
            icon: 'percent'
          },
          {
            path: '/cementerios/trasladofol',
            label: 'Traslado de Folios',
            icon: 'exchange-alt'
          },
          {
            path: '/cementerios/traslados',
            label: 'Traslados por Ubicación',
            icon: 'map-marked-alt'
          },
          {
            path: '/cementerios/duplicados',
            label: 'Registros Duplicados',
            icon: 'copy'
          },
          {
            path: '/cementerios/multiplefecha',
            label: 'Consulta por Fecha',
            icon: 'calendar-check'
          },
          {
            path: '/cementerios/multiplenombre',
            label: 'Consulta por Nombre',
            icon: 'user-tag'
          },
          {
            path: '/cementerios/multiplercm',
            label: 'Consulta por Ubicación',
            icon: 'map-marker-alt'
          },
          {
            path: '/cementerios/conindividual',
            label: 'Consulta Individual',
            icon: 'file-alt'
          },
          {
            path: '/cementerios/consultaguad',
            label: 'Cementerio Guadalajara',
            icon: 'monument'
          },
          {
            path: '/cementerios/consultajardin',
            label: 'Cementerio Jardín',
            icon: 'leaf'
          },
          {
            path: '/cementerios/consultamezq',
            label: 'Cementerio Mezquitán',
            icon: 'cross'
          },
          {
            path: '/cementerios/consultasandres',
            label: 'Cementerio San Andrés',
            icon: 'church'
          },
          {
            path: '/cementerios/estad-adeudo',
            label: 'Estadísticas de Adeudos',
            icon: 'chart-bar'
          },
          {
            path: '/cementerios/list-mov',
            label: 'Listado de Movimientos',
            icon: 'list-alt'
          },
          {
            path: '/cementerios/rep-a-cobrar',
            label: 'Reporte Cuentas por Cobrar',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/cementerios/rep-bon',
            label: 'Reporte de Bonificaciones',
            icon: 'percentage'
          },
          {
            path: '/cementerios/abcpagosxfol',
            label: 'Gestión de Pagos',
            icon: 'money-check-alt'
          },
          {
            path: '/cementerios/consultarcm',
            label: 'Consulta RCM',
            icon: 'search-location'
          },
          {
            path: '/cementerios/consulta400',
            label: 'Consulta Especial 400',
            icon: 'search-plus'
          },
          {
            path: '/cementerios/bonificacion1',
            label: 'Bonificaciones con Oficio',
            icon: 'file-signature'
          },
          {
            path: '/cementerios/consultanombre',
            label: 'Consulta por Nombre',
            icon: 'user-search'
          },
          {
            path: '/cementerios/rpttitulos',
            label: 'Reporte de Títulos',
            icon: 'file-certificate'
          },
          {
            path: '/cementerios/titulossin',
            label: 'Generar Títulos',
            icon: 'file-contract'
          },
          {
            path: '/cementerios/trasladofolsin',
            label: 'Traslado de Folios',
            icon: 'exchange-alt'
          }
        ]
      },
      
      {
        label: 'Mercados',
        icon: 'store',
        expanded: true,
        children: [
          {
            path: '/mercados/padron-locales',
            label: '* Padrón de Locales',
            icon: 'list'
          },
          {
            path: '/mercados/locales-mtto',
            label: '* Mantenimiento de Locales',
            icon: 'store-alt'
          },
          {
            path: '/mercados/adeudos-locales',
            label: '* Adeudos de Locales',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/mercados/alta-pagos',
            label: '* Alta de Pagos',
            icon: 'cash-register'
          },
          {
            path: '/mercados/emision-locales',
            label: '* Emisión de Recibos',
            icon: 'receipt'
          },
          {
            path: '/mercados/estad-pagos-adeudos',
            label: '* Estadística Pagos/Adeudos',
            icon: 'chart-bar'
          },
          {
            path: '/mercados/carga-pag-locales',
            label: '* Carga de Pagos',
            icon: 'file-import'
          },
          {
            path: '/mercados/listados-locales',
            label: '* Listados de Locales',
            icon: 'table'
          },
          {
            path: '/mercados/rpt-pagos-locales',
            label: '* Reporte de Pagos de Locales',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/mercados/padron-energia',
            label: '* Padrón de Energía Eléctrica',
            icon: 'bolt'
          },
          {
            path: '/mercados/energia-mtto',
            label: '* Alta de Energía Eléctrica',
            icon: 'plus-circle'
          },
          {
            path: '/mercados/adeudos-energia',
            label: '* Adeudos de Energía Eléctrica',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/mercados/catalogo-mercados',
            label: '* Catálogo de Mercados',
            icon: 'building'
          },
          {
            path: '/mercados/consulta-datos-locales',
            label: '* Consulta de Datos de Locales',
            icon: 'search'
          },
          {
            path: '/mercados/consulta-datos-energia',
            label: '* Consulta de Datos de Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/cuotas-mdo',
            label: '* Cuotas de Mercados',
            icon: 'dollar-sign'
          },
          {
            path: '/mercados/categoria',
            label: '* Catálogo de Categorías',
            icon: 'tags'
          },
          {
            path: '/mercados/giros',
            label: '* Giros Comerciales',
            icon: 'store'
          },
          {
            path: '/mercados/secciones',
            label: '* Secciones de Mercados',
            icon: 'th-large'
          },
          {
            path: '/mercados/recaudadoras-mercados',
            label: '* Administración de Recaudadoras',
            icon: 'building-columns'
          },
          {
            path: '/mercados/zonas-mercados',
            label: '* Zonas Geográficas',
            icon: 'map-marked-alt'
          },
          {
            path: '/mercados/reporte-general-mercados',
            label: '--- Reporte General y Estadísticas',
            icon: 'chart-pie'
          },
          {
            path: '/mercados/rpt-padron-global',
            label: '* Padrón Global de Locales',
            icon: 'table'
          },
          {
            path: '/mercados/alta-pagos-energia',
            label: '* Alta de Pagos de Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/cons-pagos',
            label: '* Consulta de Pagos',
            icon: 'money-bill-wave'
          },
          {
            path: '/mercados/pagos-individual',
            label: '* Consulta Individual de Pagos',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/mercados/cuotas-energia',
            label: '* Cuotas de Energía',
            icon: 'plug'
          },
          {
            path: '/mercados/emision-energia',
            label: '*  Emisión de Recibos de Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/cuotas-energia-mntto',
            label: '* Mantenimiento de Cuotas de Energía',
            icon: 'wrench'
          },
          {
            path: '/mercados/datos-convenio',
            label: '* Datos de Convenio',
            icon: 'handshake'
          },
          {
            path: '/mercados/datos-individuales',
            label: '*  Datos Individuales del Local',
            icon: 'file-alt'
          },
          {
            path: '/mercados/estadisticas',
            label: '--- Estadísticas de Adeudos',
            icon: 'chart-bar'
          },
          // LOTE 11: Acceso y Gestión de Requerimientos
          {
            path: '/mercados/acceso',
            label: 'Acceso al Sistema',
            icon: 'sign-in-alt'
          },
          {
            path: '/mercados/catalogo-mntto',
            label: '* Catálogo de Mercados (Mntto)',
            icon: 'edit'
          },
          {
            path: '/mercados/cons-requerimientos',
            label: '* Consulta de Requerimientos',
            icon: 'exclamation-triangle'
          },
          {
            path: '/mercados/condonacion',
            label: '* Condonación de Adeudos',
            icon: 'hand-holding-usd'
          },
          {
            path: '/mercados/ade-global-locales',
            label: '* Adeudo Global de Locales',
            icon: 'file-invoice-dollar'
          },
          // LOTE 12: Reportes de Adeudos Generales y Autorización
          {
            path: '/mercados/ade-energia-grl',
            label: '* Adeudos Generales de Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/adeudos-loc-grl',
            label: '* Adeudos Generales del Mercado',
            icon: 'exclamation-circle'
          },
          {
            path: '/mercados/aut-carga-pagos',
            label: '* Autorizar Carga de Pagos',
            icon: 'lock'
          },
          {
            path: '/mercados/aut-carga-pagos-mtto',
            label: '* Autorizar Fecha de Ingreso',
            icon: 'calendar-check'
          },
          {
            path: '/mercados/carga-diversos-esp',
            label: '* Carga Especial Pagos Diversos',
            icon: 'upload'
          },
          // LOTE 13: Carga de Pagos y Importación
          {
            path: '/mercados/carga-pag-energia',
            label: '* Carga Pagos de Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/carga-pag-energia-elec',
            label: '* Carga Pagos Energía (Rango)',
            icon: 'bolt'
          },
          {
            path: '/mercados/carga-pag-especial',
            label: '* Carga Especial Años Anteriores',
            icon: 'calendar-alt'
          },
          {
            path: '/mercados/carga-pag-mercado',
            label: '* Carga Pagos por Mercado',
            icon: 'store'
          },
          {
            path: '/mercados/carga-pagos-texto',
            label: '*** Importar Pagos desde Archivo',
            icon: 'file-import'
          },
          // LOTE 14: Componentes de Consulta y Captura
          {
            path: '/mercados/categoria-mntto',
            label: '* Mantenimiento de Categorías',
            icon: 'tags'
          },
          {
            path: '/mercados/cons-captura-energia',
            label: '* Consulta Captura Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/cons-captura-fecha',
            label: '* Consulta Captura por Fecha',
            icon: 'calendar-check'
          },
          {
            path: '/mercados/cons-captura-fecha-energia',
            label: '* Consulta Energía por Fecha',
            icon: 'calendar-days'
          },
          {
            path: '/mercados/cons-captura-merc',
            label: '* Consulta por Mercado',
            icon: 'shopping-cart'
          },
          // LOTE 15: Consultas y Condonaciones
          {
            path: '/mercados/cons-pagos-energia',
            label: '* Consulta Pagos Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/cons-pagos-locales',
            label: '* Consulta Pagos Locales',
            icon: 'store'
          },
          {
            path: '/mercados/consulta-general',
            label: '*  Consulta General',
            icon: 'search'
          },
          {
            path: '/mercados/cons-condonacion',
            label: '* Condonaciones Locales',
            icon: 'hand-holding-usd'
          },
          {
            path: '/mercados/cons-condonacion-energia',
            label: '* Condonaciones Energía',
            icon: 'bolt'
          },
          // LOTE 16: Configuración y Cuotas Adicionales
          {
            path: '/mercados/cuotas-mdo-mntto',
            label: '* Mantenimiento Cuotas Mercado',
            icon: 'edit'
          },
          {
            path: '/mercados/cve-cuota',
            label: '* Claves de Cuota',
            icon: 'key'
          },
          {
            path: '/mercados/cve-diferencias',
            label: '* Claves de Diferencias',
            icon: 'balance-scale'
          },
          {
            path: '/mercados/fecha-descuento',
            label: '*  Fechas de Descuento',
            icon: 'calendar-check'
          },
          {
            path: '/mercados/fechas-descuento-mntto',
            label: '* Mantenimiento Fechas Descuento',
            icon: 'calendar-check'
          },
          {
            path: '/mercados/recargos',
            label: '* Configuración de Recargos',
            icon: 'percent'
          },
          // LOTE 17: Datos de Locales y Energía
          {
            path: '/mercados/datos-movimientos',
            label: '*  Datos de Movimientos',
            icon: 'exchange-alt'
          },
          {
            path: '/mercados/datos-requerimientos',
            label: '*  Datos de Requerimientos',
            icon: 'file-invoice'
          },
          {
            path: '/mercados/locales-modif',
            label: '* Modificar Locales',
            icon: 'pen'
          },
          {
            path: '/mercados/energia-modif',
            label: '--- Modificar Energía',
            icon: 'plug'
          },
          // LOTE 18: Emisión y Consultas de Pagos
          {
            path: '/mercados/emision-libertad',
            label: '* Emisión Libertad',
            icon: 'dove'
          },
          {
            path: '/mercados/pagos-ene-cons',
            label: '* Consulta Pagos Energía',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/mercados/pagos-loc-grl',
            label: '--- Pagos Locales General',
            icon: 'chart-bar'
          },
          // LOTE 19: Condonaciones y Prescripción
          {
            path: '/mercados/prescripcion',
            label: '--- Prescripción de Adeudos',
            icon: 'hourglass-end'
          },
          {
            path: '/mercados/rep-adeud-cond',
            label: '--- Reporte Adeudos Condonados',
            icon: 'list-ul'
          },
          // LOTE 20: Reportes de Adeudos
          {
            path: '/mercados/rpt-ade-energia-grl',
            label: '* Reporte Adeudos Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/rpt-adeudos-locales',
            label: '* Reporte Adeudos Locales',
            icon: 'store-slash'
          },
          {
            path: '/mercados/rpt-adeudos-energia',
            label: '--- Reporte Adeudos Energía Detalle',
            icon: 'plug'
          },
          {
            path: '/mercados/rpt-adeudos-anteriores',
            label: '* Reporte Adeudos Anteriores',
            icon: 'history'
          },
          {
            path: '/mercados/rpt-adeudos-abastos1998',
            label: '* Reporte Abastos 1998',
            icon: 'calendar-times'
          },
          {
            path: '/mercados/rpt-desgloce-ade-porimporte',
            label: '*  Desglose Adeudos por Año',
            icon: 'layer-group'
          },
          // LOTE 21: Reportes de Emisión
          {
            path: '/mercados/rpt-emision-locales',
            label: '* Reporte Emisión con Multas',
            icon: 'file-invoice'
          },
          {
            path: '/mercados/rpt-emision-rbos-abastos',
            label: '--- Reporte Emisión Abastos',
            icon: 'shopping-basket'
          },
          {
            path: '/mercados/rpt-emision-laser',
            label: '--- Reporte Emisión Laser',
            icon: 'barcode'
          },
          {
            path: '/mercados/rpt-emision-energia',
            label: '* Reporte Recibos Energía',
            icon: 'bolt'
          },
          // LOTE 22: Reportes de Facturación
          {
            path: '/mercados/rpt-factura-emision',
            label: '--- Reporte Factura Emisión',
            icon: 'file-pdf'
          },
          {
            path: '/mercados/rpt-factura-energia',
            label: '--- Reporte Factura Energía',
            icon: 'file-contract'
          },
          {
            path: '/mercados/rpt-factura-glunes',
            label: '--- Reporte Facturación Global',
            icon: 'file-signature'
          },
          // LOTE 23: Reportes de Padrones e Ingresos
          {
            path: '/mercados/rpt-padron-locales',
            label: '* Reporte Padrón Locales',
            icon: 'building'
          },
          {
            path: '/mercados/rpt-padron-energia',
            label: '* Reporte Padrón Energía',
            icon: 'bolt'
          },
          {
            path: '/mercados/rpt-locales-giro',
            label: '--- Reporte Locales por Giro',
            icon: 'store'
          },
          {
            path: '/mercados/rpt-mercados',
            label: '--- Reporte Catálogo Mercados',
            icon: 'map'
          },
          {
            path: '/mercados/rpt-zonificacion',
            label: '--- Reporte Zonificación',
            icon: 'map-marker-alt'
          },
          {
            path: '/mercados/rpt-movimientos',
            label: '--- Reporte Movimientos',
            icon: 'exchange-alt'
          },
          {
            path: '/mercados/ingreso-captura',
            label: '*  Ingreso Captura',
            icon: 'keyboard'
          },
          {
            path: '/mercados/ingreso-lib',
            label: '*  Ingresos Libertad',
            icon: 'book-open'
          },
          {
            path: '/mercados/rpt-ingreso-zonificado',
            label: '--- Reporte Ingresos por Zona',
            icon: 'map-marked-alt'
          },
          // LOTE 24: Reportes de Ingresos
          {
            path: '/mercados/rpt-ingresos',
            label: '--- Reporte Ingresos Locales',
            icon: 'money-bill-wave'
          },
          {
            path: '/mercados/rpt-ingresos-energia',
            label: '--- Reporte Ingresos Energía',
            icon: 'lightbulb'
          },
          // LOTE 25: Reportes de Pagos
          {
            path: '/mercados/rpt-pagos-ano',
            label: '--- Reporte Pagos por Año',
            icon: 'calendar-alt'
          },
          {
            path: '/mercados/rpt-pagos-caja',
            label: '--- Reporte Pagos por Caja',
            icon: 'cash-register'
          },
          {
            path: '/mercados/rpt-pagos-detalle',
            label: '--- Reporte Detalle de Pagos',
            icon: 'file-alt'
          },
          {
            path: '/mercados/rpt-pagos-grl',
            label: '--- Reporte Pagos Generales',
            icon: 'chart-bar'
          },
          // LOTE 26: Estadísticas y Reportes Finales
          {
            path: '/mercados/rpt-estad-pagos-y-adeudos',
            label: '* Estadística Pagos y Adeudos',
            icon: 'chart-area'
          },
          {
            path: '/mercados/rpt-estadistica-adeudos',
            label: '* Estadística de Adeudos',
            icon: 'chart-line'
          },
          {
            path: '/mercados/cuenta-publica',
            label: '*  Cuenta Pública',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/mercados/rpt-cuenta-publica',
            label: '* Reporte Cuenta Pública',
            icon: 'receipt'
          },
          {
            path: '/mercados/pagos-dif-ingresos',
            label: '*  Diferencias en Ingresos',
            icon: 'exclamation-circle'
          },
          // LOTE 27: Reportes Finales y Configuración
          {
            path: '/mercados/rpt-resumen-pagos',
            label: '--- Resumen de Pagos',
            icon: 'file-signature'
          },
          {
            path: '/mercados/rpt-saldos-locales',
            label: '--- Saldos de Locales',
            icon: 'balance-scale'
          },
          {
            path: '/mercados/rpt-fechas-vencimiento',
            label: '* Fechas de Vencimiento',
            icon: 'calendar-times'
          },
          {
            path: '/mercados/rpt-catalogo-merc',
            label: '* Catálogo de Mercados (Reporte)',
            icon: 'building'
          },
          // Paso de Datos
          {
            path: '/mercados/paso-adeudos',
            label: '* Paso de Adeudos',
            icon: 'arrow-circle-right'
          },
          {
            path: '/mercados/paso-ene',
            label: '* Importar Energía',
            icon: 'file-import'
          },
          {
            path: '/mercados/paso-mdos',
            label: '* Paso Tianguis',
            icon: 'database'
          },
          // Menú Principal
          {
            path: '/mercados/menu',
            label: 'Menú de Mercados',
            icon: 'th'
          }
        ]
      }
    ]
  },
  {
    label: 'Regulaciones',
    icon: 'gavel',
    children: [
      {
        label: 'Multas y Reglamentos',
        icon: 'file-contract',
        children: [
          { path: '/multas-reglamentos', label: 'Menú Principal', icon: 'home' },
          { path: '/multas-reglamentos/ActualizaFechaEmpresas', label: 'ActualizaFechaEmpresas', icon: 'file' },
          { path: '/multas-reglamentos/AplicaSdosFavor', label: 'AplicaSdosFavor', icon: 'file' },
          { path: '/multas-reglamentos/BloqueoMulta', label: 'BloqueoMulta', icon: 'file' },
          { path: '/multas-reglamentos/CapturaDif', label: 'CapturaDif', icon: 'file' },
          { path: '/multas-reglamentos/CartaInvitacion', label: 'CartaInvitacion', icon: 'file' },
          { path: '/multas-reglamentos/CatastroDM', label: 'CatastroDM', icon: 'file' },
          { path: '/multas-reglamentos/ConsReq400', label: 'ConsReq400', icon: 'file' },
          { path: '/multas-reglamentos/DescDerechosMerc', label: 'DescDerechosMerc', icon: 'file' },
          { path: '/multas-reglamentos/DrecgoFosa', label: 'DrecgoFosa', icon: 'file' },
          { path: '/multas-reglamentos/DrecgoTrans', label: 'DrecgoTrans', icon: 'file' },
          { path: '/multas-reglamentos/Ejecutores', label: 'Ejecutores', icon: 'file' },
          { path: '/multas-reglamentos/Empresas', label: 'Empresas', icon: 'file' },
          { path: '/multas-reglamentos/Exclusivos_Upd', label: 'Exclusivos_Upd', icon: 'file' },
          { path: '/multas-reglamentos/ExtractosRpt', label: 'ExtractosRpt', icon: 'file' },
          { path: '/multas-reglamentos/FirmaElectronica', label: 'FirmaElectronica', icon: 'file' },
          { path: '/multas-reglamentos/FolMulta', label: 'FolMulta', icon: 'file' },
          { path: '/multas-reglamentos/FrmEje', label: 'FrmEje', icon: 'file' },
          { path: '/multas-reglamentos/GastosTransmision', label: 'GastosTransmision', icon: 'file' },
          { path: '/multas-reglamentos/Hastafrm', label: 'Hastafrm', icon: 'file' },
          { path: '/multas-reglamentos/ImpresionNva', label: 'ImpresionNva', icon: 'file' },
          { path: '/multas-reglamentos/ImprimeDesctos', label: 'ImprimeDesctos', icon: 'file' },
          { path: '/multas-reglamentos/LicenciaMicrogenerador', label: 'LicenciaMicrogenerador', icon: 'file' },
          { path: '/multas-reglamentos/LicenciaMicrogeneradorEcologia', label: 'LicenciaMicrogeneradorEcologia', icon: 'file' },
          { path: '/multas-reglamentos/ListAna', label: 'ListAna', icon: 'file' },
          { path: '/multas-reglamentos/ListaDiferencias', label: 'ListaDiferencias', icon: 'file' },
          { path: '/multas-reglamentos/ListadoMultiple', label: 'ListadoMultiple', icon: 'file' },
          { path: '/multas-reglamentos/ModifMasiva', label: 'ModifMasiva', icon: 'file' },
          { path: '/multas-reglamentos/MultasDM', label: 'MultasDM', icon: 'file' },
          { path: '/multas-reglamentos/Otorgadescto', label: 'Otorgadescto', icon: 'file' },
          { path: '/multas-reglamentos/PagosEspe', label: 'PagosEspe', icon: 'file' },
          { path: '/multas-reglamentos/PeriodoInicial', label: 'PeriodoInicial', icon: 'file' },
          { path: '/multas-reglamentos/Propuestatab', label: 'Propuestatab', icon: 'file' },
          { path: '/multas-reglamentos/Publicos_Upd', label: 'Publicos_Upd', icon: 'file' },
          { path: '/multas-reglamentos/RegSecyMas', label: 'RegSecyMas', icon: 'file' },
          { path: '/multas-reglamentos/RepDescImpto', label: 'RepDescImpto', icon: 'file' },
          { path: '/multas-reglamentos/RepOper', label: 'RepOper', icon: 'file' },
          { path: '/multas-reglamentos/Req', label: 'Req', icon: 'file' },
          { path: '/multas-reglamentos/ReqFrm', label: 'ReqFrm', icon: 'file' },
          { path: '/multas-reglamentos/ReqPromocion', label: 'ReqPromocion', icon: 'file' },
          { path: '/multas-reglamentos/ReqTrans', label: 'ReqTrans', icon: 'file' },
          { path: '/multas-reglamentos/RequerimientosDM', label: 'RequerimientosDM', icon: 'file' },
          { path: '/multas-reglamentos/RequerxCvecat', label: 'RequerxCvecat', icon: 'file' },
          { path: '/multas-reglamentos/ResolucionJuez', label: 'ResolucionJuez', icon: 'file' },
          { path: '/multas-reglamentos/SdosFavorDM', label: 'SdosFavorDM', icon: 'file' },
          { path: '/multas-reglamentos/SdosFavor_CtrlExp', label: 'SdosFavor_CtrlExp', icon: 'file' },
          { path: '/multas-reglamentos/SdosFavor_Pagos', label: 'SdosFavor_Pagos', icon: 'file' },
          { path: '/multas-reglamentos/SinLigarFrm', label: 'SinLigarFrm', icon: 'file' },
          { path: '/multas-reglamentos/SolSdosFavor', label: 'SolSdosFavor', icon: 'file' },
          { path: '/multas-reglamentos/TDMConection', label: 'TDMConection', icon: 'file' },
          { path: '/multas-reglamentos/Ubicodifica', label: 'Ubicodifica', icon: 'file' },
          { path: '/multas-reglamentos/autdescto', label: 'autdescto', icon: 'file' },
          { path: '/multas-reglamentos/bloqctasreqfrm', label: 'bloqctasreqfrm', icon: 'file' },
          { path: '/multas-reglamentos/busque', label: 'busque', icon: 'file' },
          { path: '/multas-reglamentos/canc', label: 'canc', icon: 'file' },
          { path: '/multas-reglamentos/centrosfrm', label: 'centrosfrm', icon: 'file' },
          { path: '/multas-reglamentos/codificafrm', label: 'codificafrm', icon: 'file' },
          { path: '/multas-reglamentos/conscentrosfrm', label: 'conscentrosfrm', icon: 'file' },
          { path: '/multas-reglamentos/consdesc', label: 'consdesc', icon: 'file' },
          { path: '/multas-reglamentos/consescrit400', label: 'consescrit400', icon: 'file' },
          { path: '/multas-reglamentos/consmulpagos', label: 'consmulpagos', icon: 'file' },
          { path: '/multas-reglamentos/consobsmulfrm', label: 'consobsmulfrm', icon: 'file' },
          { path: '/multas-reglamentos/consultapredial', label: 'consultapredial', icon: 'file' },
          { path: '/multas-reglamentos/dderechosLic', label: 'dderechosLic', icon: 'file' },
          { path: '/multas-reglamentos/descmultampalfrm', label: 'descmultampalfrm', icon: 'file' },
          { path: '/multas-reglamentos/descpredfrm', label: 'descpredfrm', icon: 'file' },
          { path: '/multas-reglamentos/desctorec', label: 'desctorec', icon: 'file' },
          { path: '/multas-reglamentos/drecgoLic', label: 'drecgoLic', icon: 'file' },
          { path: '/multas-reglamentos/drecgoOtrasObligaciones', label: 'drecgoOtrasObligaciones', icon: 'file' },
          { path: '/multas-reglamentos/entregafrm', label: 'entregafrm', icon: 'file' },
          { path: '/multas-reglamentos/estadreq', label: 'estadreq', icon: 'file' },
          { path: '/multas-reglamentos/frmpol', label: 'frmpol', icon: 'file' },
          { path: '/multas-reglamentos/impreqCvecat', label: 'impreqCvecat', icon: 'file' },
          { path: '/multas-reglamentos/ipor', label: 'ipor', icon: 'file' },
          { path: '/multas-reglamentos/leyesfrm', label: 'leyesfrm', icon: 'file' },
          { path: '/multas-reglamentos/ligapago', label: 'ligapago', icon: 'file' },
          { path: '/multas-reglamentos/ligapagoTra', label: 'ligapagoTra', icon: 'file' },
          { path: '/multas-reglamentos/listanotificacionesfrm', label: 'listanotificacionesfrm', icon: 'file' },
          { path: '/multas-reglamentos/listareq', label: 'listareq', icon: 'file' },
          { path: '/multas-reglamentos/listchq', label: 'listchq', icon: 'file' },
          { path: '/multas-reglamentos/listdesctomultafrm', label: 'listdesctomultafrm', icon: 'file' },
          { path: '/multas-reglamentos/multas400frm', label: 'multas400frm', icon: 'file' },
          { path: '/multas-reglamentos/multasfrm', label: 'multasfrm', icon: 'file' },
          { path: '/multas-reglamentos/multasfrmcalif', label: 'multasfrmcalif', icon: 'file' },
          { path: '/multas-reglamentos/newsfrm', label: 'newsfrm', icon: 'file' },
          { path: '/multas-reglamentos/pagalicfrm', label: 'pagalicfrm', icon: 'file' },
          { path: '/multas-reglamentos/pagosdivfrm', label: 'pagosdivfrm', icon: 'file' },
          { path: '/multas-reglamentos/pagosmultfrm', label: 'pagosmultfrm', icon: 'file' },
          { path: '/multas-reglamentos/polcon', label: 'polcon', icon: 'file' },
          { path: '/multas-reglamentos/prepagofrm', label: 'prepagofrm', icon: 'file' },
          { path: '/multas-reglamentos/pres', label: 'pres', icon: 'file' },
          { path: '/multas-reglamentos/proyecfrm', label: 'proyecfrm', icon: 'file' },
          { path: '/multas-reglamentos/pruebacalcas', label: 'pruebacalcas', icon: 'file' },
          { path: '/multas-reglamentos/psplash', label: 'psplash', icon: 'file' },
          { path: '/multas-reglamentos/reg', label: 'reg', icon: 'file' },
          { path: '/multas-reglamentos/regHfrm', label: 'regHfrm', icon: 'file' },
          { path: '/multas-reglamentos/reimpfrm', label: 'reimpfrm', icon: 'file' },
          { path: '/multas-reglamentos/relmes', label: 'relmes', icon: 'file' },
          { path: '/multas-reglamentos/repavance', label: 'repavance', icon: 'file' },
          { path: '/multas-reglamentos/repmultampalfrm', label: 'repmultampalfrm', icon: 'file' },
          { path: '/multas-reglamentos/reqctascanfrm', label: 'reqctascanfrm', icon: 'file' },
          { path: '/multas-reglamentos/reqmultas400frm', label: 'reqmultas400frm', icon: 'file' },
          { path: '/multas-reglamentos/sfrm_calificacionQR', label: 'sfrm_calificacionQR', icon: 'file' },
          { path: '/multas-reglamentos/sfrm_chgpass', label: 'sfrm_chgpass', icon: 'file' },
          { path: '/multas-reglamentos/sfrm_prescrip_sec01', label: 'sfrm_prescrip_sec01', icon: 'file' },
          { path: '/multas-reglamentos/sgcv2', label: 'sgcv2', icon: 'file' },
          { path: '/multas-reglamentos/trasladosfrm', label: 'trasladosfrm', icon: 'file' }
        ]
      },
      {
        label: 'Otras Obligaciones',
        icon: 'file-lines',
        children: [
          {
            path: '/otras_obligaciones',
            label: 'Menú Principal',
            icon: 'home'
      },
      
          {
            path: '/otras_obligaciones/apremios',
            label: '* Apremios',
            icon: 'gavel'
          },
          {
            path: '/otras_obligaciones/aux-rep',
            label: '* Padrón de Concesionarios',
            icon: 'users'
          },
          {
            path: '/otras_obligaciones/carga-cartera',
            label: '* Carga de Cartera',
            icon: 'upload'
          },
          {
            path: '/otras_obligaciones/carga-valores',
            label: '* Carga de Valores',
            icon: 'dollar-sign'
          },
          {
            path: '/otras_obligaciones/etiquetas',
            label: '* Catálogo de Etiquetas',
            icon: 'tags'
          },
          {
            path: '/otras_obligaciones/gactualiza',
            label: '* Actualización de Datos',
            icon: 'edit'
          },
          {
            path: '/otras_obligaciones/gadeudos',
            label: '* Adeudos',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/otras_obligaciones/gadeudos-gral',
            label: '* Adeudos Generales',
            icon: 'list-alt'
          },
          {
            path: '/otras_obligaciones/gadeudos-opc-mult',
            label: '* Opciones Múltiples',
            icon: 'tasks'
          },
          {
            path: '/otras_obligaciones/gadeudos-opc-mult-ra',
            label: '* Reactivación',
            icon: 'redo'
          },
          {
            path: '/otras_obligaciones/gbaja',
            label: '* Baja de Registros',
            icon: 'trash-alt'
          },
          {
            path: '/otras_obligaciones/gconsulta',
            label: '* Consulta',
            icon: 'search'
          },
          {
            path: '/otras_obligaciones/gconsulta2',
            label: '* Consulta Avanzada',
            icon: 'search-plus'
          },
          {
            path: '/otras_obligaciones/gfacturacion',
            label: '* Facturación',
            icon: 'file-invoice'
          },
          {
            path: '/otras_obligaciones/gnuevos',
            label: '* Nuevos Registros',
            icon: 'plus-circle'
          },
          {
            path: '/otras_obligaciones/grep-padron',
            label: '* Reporte Padrón',
            icon: 'file-alt'
          },
          {
            path: '/otras_obligaciones/ractualiza',
            label: '* R. Actualizaciones',
            icon: 'chart-line'
          },
          {
            path: '/otras_obligaciones/radeudos',
            label: '* R. Adeudos',
            icon: 'file-invoice'
          },
          {
            path: '/otras_obligaciones/radeudos-opc-mult',
            label: '* R. Opciones Múltiples',
            icon: 'clipboard-list'
          },
          {
            path: '/otras_obligaciones/rbaja',
            label: '* R. Bajas',
            icon: 'ban'
          },
          {
            path: '/otras_obligaciones/rconsulta',
            label: '* R. Consulta',
            icon: 'file-search'
          },
          {
            path: '/otras_obligaciones/rfacturacion',
            label: '* R. Facturación',
            icon: 'file-invoice-dollar'
          },
          {
            path: '/otras_obligaciones/rnuevos',
            label: '* R. Nuevos',
            icon: 'file-plus'
          },
          {
            path: '/otras_obligaciones/rpagados',
            label: '* R. Pagados',
            icon: 'file-check'
          },
          {
            path: '/otras_obligaciones/rrep-padron',
            label: '* R. Rep. Padrón',
            icon: 'file-export'
          },
          {
            path: '/otras_obligaciones/rubros',
            label: '* Rubros',
            icon: 'list'
          }
        ]
      }
    ]
  },
  {
    label: 'Licencias',
    icon: 'id-badge',
    children: [
      {
        label: 'Padrón de Licencias',
        icon: 'id-card',
        children: [
          {
            label: 'Catálogos Adicionales',
            icon: 'folder-tree',
            children: [
              {
                path: '/padron-licencias/grupos-anuncios',
                label: 'Grupos de Anuncios',
                icon: 'bullhorn'
              },
              {
                path: '/padron-licencias/grupos-anuncios-abc',
                label: 'Grupos de Anuncios ABC',
                icon: 'bullhorn'
              },
              {
                path: '/padron-licencias/zona-licencia',
                label: 'Zonas de Licencias',
                icon: 'map-marked-alt'
              },
              {
                path: '/padron-licencias/privilegios',
                label: 'Privilegios de Usuario',
                icon: 'user-shield'
              },
              {
                path: '/padron-licencias/unidad-img',
                label: 'Configuración de Imágenes',
                icon: 'folder-open'
              }
            ]
          },
          {
            label: 'Consultas Históricas y Especiales',
            icon: 'history',
            children: [
              {
                path: '/padron-licencias/dependencias',
                label: 'Gestión de Dependencias',
                icon: 'clipboard-check'
              },
              {
                path: '/padron-licencias/estatus',
                label: 'Cambio de Estatus de Revisión',
                icon: 'exchange-alt'
              },
              {
                path: '/padron-licencias/giros-vigentes-cte-xgiro',
                label: 'Giros Vigentes por Contribuyente',
                icon: 'chart-line'
              },
              {
                path: '/padron-licencias/consulta-licencias-400',
                label: 'Consulta Licencias AS/400',
                icon: 'database'
              },
              {
                path: '/padron-licencias/consulta-anuncios-400',
                label: 'Consulta Anuncios AS/400',
                icon: 'database'
              }
            ]
          },
          {
            label: 'Herramientas Auxiliares',
            icon: 'tools',
            children: [
              {
                path: '/padron-licencias/formabuscalle',
                label: 'Búsqueda de Calles',
                icon: 'road'
              },
              {
                path: '/padron-licencias/formabuscolonia',
                label: 'Búsqueda de Colonias',
                icon: 'map-marked-alt'
              },
              {
                path: '/padron-licencias/frmselcalle',
                label: 'Selector de Calles',
                icon: 'map-signs'
              },
              {
                path: '/padron-licencias/sfrm-chgfirma',
                label: 'Cambio de Firma',
                icon: 'key'
              },
              {
                path: '/padron-licencias/tipobloqueo',
                label: 'Tipos de Bloqueo',
                icon: 'ban'
              }
            ]
          },
          {
            label: 'Herramientas del Sistema',
            icon: 'tools',
            children: [
              {
                path: '/padron-licencias/bienvenida',
                label: 'Pantalla de Bienvenida',
                icon: 'rocket'
              },
              {
                path: '/padron-licencias/registro-historico',
                label: 'Registro Histórico',
                icon: 'history'
              },
              {
                path: '/padron-licencias/sgc-v2',
                label: 'Sistema de Gestión de Calidad',
                icon: 'chart-line'
              },
              {
                path: '/padron-licencias/tdm-conexion',
                label: 'Conexión TDM',
                icon: 'sync-alt'
              },
              {
                path: '/padron-licencias/navegador-web',
                label: 'Navegador Web',
                icon: 'globe'
              },
              {
                path: '/padron-licencias/dialogo-giros',
                label: 'Selector de Giros',
                icon: 'list-ul'
              },
              {
                path: '/padron-licencias/imp-licencia-reglamentada',
                label: 'Imprimir Licencia Reglamentada',
                icon: 'print'
              }
            ]
          },
          {
            label: 'Impresión y Digitalización',
            icon: 'print',
            children: [
              {
                path: '/padron-licencias/historial-bloqueo-domicilios',
                label: 'Historial Bloqueo Domicilios',
                icon: 'history'
              },
              {
                path: '/padron-licencias/giros-con-adeudo',
                label: 'Giros con Adeudo',
                icon: 'file-invoice-dollar'
              },
              {
                path: '/padron-licencias/impresion-licencias-reglamentadas',
                label: 'Impresión Licencias Reglamentadas',
                icon: 'print'
              },
              {
                path: '/padron-licencias/carga-imagenes',
                label: 'Carga de Imágenes',
                icon: 'images'
              },
              {
                path: '/padron-licencias/firma-digital',
                label: 'Firma Digital',
                icon: 'signature'
              }
            ]
          },
          {
            label: 'Reportes',
            icon: 'chart-bar',
            children: [
              {
                path: '/padron-licencias/reporte-documentos',
                label: 'Reporte de Documentos',
                icon: 'file-alt'
              },
              {
                path: '/padron-licencias/reporte-estadisticos',
                label: 'Reportes Estadísticos',
                icon: 'chart-line'
              },
              {
                path: '/padron-licencias/reporte-estado',
                label: 'Estado de Trámites',
                icon: 'tasks'
              },
              {
                path: '/padron-licencias/reporte-suspendidas',
                label: 'Licencias Suspendidas',
                icon: 'ban'
              },
              {
                path: '/padron-licencias/reporte-anuncios-excel',
                label: 'Reporte de Anuncios',
                icon: 'file-excel'
              }
            ]
          },
          {
            label: 'Trámites',
            icon: 'file-signature',
            children: [
              {
                path: '/padron-licencias/registro-solicitud',
                label: 'Registro de Solicitud',
                icon: 'file-plus'
              },
              {
                path: '/padron-licencias/consulta-tramites',
                label: 'Consulta de Trámites',
                icon: 'search'
              },
              {
                path: '/padron-licencias/modificacion-tramites',
                label: 'Modificación de Trámites',
                icon: 'edit'
              },
              {
                path: '/padron-licencias/bloquear-tramite',
                label: 'Bloquear Trámite',
                icon: 'ban'
              },
              {
                path: '/padron-licencias/cancelacion-tramites',
                label: 'Cancelación de Trámites',
                icon: 'times-circle'
              },
              {
                path: '/padron-licencias/reactivar-tramite',
                label: 'Reactivar Trámite',
                icon: 'redo'
              },
              {
                path: '/padron-licencias/documentos',
                label: 'Documentos de Trámites',
                icon: 'file-alt'
              },
              {
                path: '/padron-licencias/tramite-baja-anuncio',
                label: 'Trámite Baja de Anuncio',
                icon: 'ban'
              },
              {
                path: '/padron-licencias/tramite-baja-licencia',
                label: 'Trámite Baja de Licencia',
                icon: 'file-excel'
              }
            ]
          },
          {
            label: 'Trámites Especializados',
            icon: 'file-signature',
            children: [
              {
                path: '/padron-licencias/agenda-visitas',
                label: 'Agenda de Visitas',
                icon: 'calendar-check'
              },
              {
                path: '/padron-licencias/dictamen-uso-suelo',
                label: 'Dictamen de Uso de Suelo',
                icon: 'map'
              },
              {
                path: '/padron-licencias/formatos-ecologia',
                label: 'Formatos de Ecología',
                icon: 'leaf'
              },
              {
                path: '/padron-licencias/dictamenes',
                label: 'Dictámenes',
                icon: 'file-contract'
              },
              {
                path: '/padron-licencias/certificaciones',
                label: 'Certificaciones',
                icon: 'certificate'
              }
            ]
          },
          {
            label: 'Trámites y Procesos',
            icon: 'file-signature',
            children: [
              {
                path: '/padron-licencias/observaciones',
                label: 'Observaciones',
                icon: 'comment-alt'
              },
              {
                path: '/padron-licencias/licencias-vigentes',
                label: 'Licencias Vigentes',
                icon: 'clipboard-check'
              },
              {
                path: '/padron-licencias/sfrm-chgpass',
                label: 'Cambio de Contraseña',
                icon: 'lock'
              }
            ]
          },
          {
            label: 'Utilidades',
            icon: 'tools',
            children: [
              {
                path: '/padron-licencias/catastro-dm',
                label: 'Catastro DM',
                icon: 'building'
              },
              {
                path: '/padron-licencias/propuesta-tabulador',
                label: 'Propuesta de Tabulador',
                icon: 'table'
              },
              {
                path: '/padron-licencias/empresas',
                label: 'Empresas',
                icon: 'industry'
              },
              {
                path: '/padron-licencias/carga-datos',
                label: 'Carga de Datos',
                icon: 'upload'
              },
              {
                path: '/padron-licencias/semaforo',
                label: 'Semáforo',
                icon: 'traffic-light'
              }
            ]
          },
          {
            path: '/padron-licencias/consulta-usuarios',
            label: 'Consulta de Usuarios',
            icon: 'users'
          },
          {
            path: '/padron-licencias/consulta-licencias',
            label: 'Consulta de Licencias',
            icon: 'file-contract'
          },
          {
            path: '/padron-licencias/consulta-anuncios',
            label: 'Consulta de Anuncios',
            icon: 'store'
          },
          {
            path: '/padron-licencias/modificacion-licencias',
            label: 'Modificación de Licencias y Anuncios',
            icon: 'edit'
          },
          {
            path: '/padron-licencias/solicitud-numero-oficial',
            label: 'Solicitud Número Oficial',
            icon: 'file-contract'
          },
          {
            path: '/padron-licencias/constancias',
            label: 'Constancias',
            icon: 'file-alt'
          },
          {
            path: '/padron-licencias/dictamenes',
            label: 'Dictámenes',
            icon: 'clipboard-check'
          },
          {
            path: '/padron-licencias/baja-licencia',
            label: 'Baja de Licencia',
            icon: 'ban'
          },
          {
            path: '/padron-licencias/bloqueo-domicilios',
            label: 'Bloqueo de Domicilios',
            icon: 'lock'
          },
          {
            path: '/padron-licencias/bloqueo-rfc',
            label: 'Bloqueo de RFC',
            icon: 'ban'
          },
          {
            path: '/padron-licencias/catalogo-giros',
            label: 'Catálogo de Giros',
            icon: 'tags'
          },
          {
            path: '/padron-licencias/busqueda-giros',
            label: 'Búsqueda de Giros',
            icon: 'search'
          },
          {
            path: '/padron-licencias/catalogo-actividades',
            label: 'Catálogo de Actividades',
            icon: 'list-check'
          },
          {
            path: '/padron-licencias/catalogo-requisitos',
            label: 'Catálogo de Requisitos',
            icon: 'clipboard-list'
          },
          {
            path: '/padron-licencias/grupos-licencias',
            label: 'Grupos de Licencias',
            icon: 'layer-group'
          },
          {
            path: '/padron-licencias/cruces-calles',
            label: 'Cruces de Calles',
            icon: 'road'
          },
          {
            path: '/padron-licencias/grupos-licencias-abc',
            label: 'Grupos de Licencias ABC',
            icon: 'layer-group'
          },
          {
            path: '/padron-licencias/zona-anuncio',
            label: 'Zonas de Anuncios',
            icon: 'map-marked-alt'
          },
          {
            path: '/padron-licencias/busqueda-actividad',
            label: 'Búsqueda de Actividad',
            icon: 'search'
          },
          {
            path: '/padron-licencias/busqueda-scian',
            label: 'Búsqueda SCIAN',
            icon: 'search-dollar'
          },
          {
            path: '/padron-licencias/busqueda-general',
            label: 'Búsqueda General',
            icon: 'search-location'
          },
          {
            path: '/padron-licencias/bloquear-licencia',
            label: 'Bloquear Licencia',
            icon: 'lock'
          },
          {
            path: '/padron-licencias/bloquear-anuncio',
            label: 'Bloquear Anuncio',
            icon: 'shield-alt'
          },
          {
            path: '/padron-licencias/baja-anuncio',
            label: 'Baja de Anuncio',
            icon: 'minus-circle'
          },
          {
            path: '/padron-licencias/certificaciones',
            label: 'Certificaciones',
            icon: 'certificate'
          },
          {
            path: '/padron-licencias/agenda-visitas',
            label: 'Agenda de Visitas',
            icon: 'calendar-check'
          },
          {
            path: '/padron-licencias/dictamen-uso-suelo',
            label: 'Dictamen Uso de Suelo',
            icon: 'map-marked'
          },
          {
            path: '/padron-licencias/formatos-ecologia',
            label: 'Formatos de Ecología',
            icon: 'leaf'
          },
          {
            path: '/padron-licencias/fecha-seguimiento',
            label: 'Fecha de Seguimiento',
            icon: 'calendar-alt'
          },
          {
            path: '/padron-licencias/firma-usuario',
            label: 'Firma de Usuario',
            icon: 'signature'
          },
          {
            path: '/padron-licencias/liga-anuncio',
            label: 'Liga de Anuncios',
            icon: 'link'
          },
          {
            path: '/padron-licencias/liga-requisitos',
            label: 'Liga de Requisitos',
            icon: 'link'
          },
          {
            path: '/padron-licencias/modific-adeudo',
            label: 'Modificación de Adeudos',
            icon: 'edit'
          },
          {
            path: '/padron-licencias/prepago',
            label: 'Prepago de Licencias',
            icon: 'dollar-sign'
          },
          {
            path: '/padron-licencias/propietarios-hologramas',
            label: 'Propietarios de Hologramas',
            icon: 'id-card-alt'
          },
          {
            path: '/padron-licencias/responsivas',
            label: 'Responsivas',
            icon: 'file-signature'
          },
          {
            path: '/padron-licencias/hasta',
            label: 'Pagar Hasta',
            icon: 'calendar-check'
          },
          {
            path: '/padron-licencias/cartografia-catastral',
            label: 'Cartografía Catastral',
            icon: 'map'
          },
          {
            path: '/padron-licencias/carga-predios',
            label: 'Carga de Predios',
            icon: 'building'
          },
          {
            path: '/padron-licencias/imp-licencia-reglamentada',
            label: 'Imprimir Licencia Reglamentada',
            icon: 'print'
          },
          {
            path: '/padron-licencias/imp-oficio',
            label: 'Imprimir Oficio',
            icon: 'file-invoice'
          },
          {
            path: '/padron-licencias/imp-recibo',
            label: 'Imprimir Recibo',
            icon: 'receipt'
          }
        ]
      }
    ]
  }
]

// Función recursiva para filtrar items manteniendo la jerarquía
const filterMenuItems = (items, query) => {
  if (!query || query.trim() === '') {
    return items
  }

  const searchTerm = query.toLowerCase().trim()
  const filtered = []

  for (const item of items) {
    // Verificar si el item actual coincide con la búsqueda
    const itemMatches = item.label.toLowerCase().includes(searchTerm)

    // Si tiene hijos, filtrar recursivamente
    if (item.children && item.children.length > 0) {
      const filteredChildren = filterMenuItems(item.children, query)

      // Si el item actual coincide O tiene hijos que coinciden, incluirlo
      if (itemMatches || filteredChildren.length > 0) {
        filtered.push({
          ...item,
          children: filteredChildren,
          _forceExpanded: filteredChildren.length > 0 // Expandir automáticamente si tiene hijos filtrados
        })
      }
    } else {
      // Es un nodo hoja, incluir solo si coincide
      if (itemMatches) {
        filtered.push(item)
      }
    }
  }

  return filtered
}

// Ordenación alfabética (insensible a acentos y mayúsculas)
const collator = new Intl.Collator('es', { sensitivity: 'base', numeric: true })
const sortMenu = (items) => {
  // Copia y ordena por label; aplica recursivamente en children
  const mapped = items.map((item) => {
    if (item.children && item.children.length > 0) {
      return { ...item, children: sortMenu(item.children) }
    }
    return item
  })

  // Separar Dashboard (siempre primero) del resto
  const dashboard = mapped.find(item => item.path === '/')
  const restItems = mapped.filter(item => item.path !== '/')

  // Separar subgrupos (con children) e items sueltos (sin children)
  const subgroups = restItems.filter(item => item.children && item.children.length > 0)
  const singleItems = restItems.filter(item => !item.children || item.children.length === 0)

  // Ordenar cada grupo alfabéticamente
  const sortedSubgroups = subgroups.sort((a, b) => collator.compare(a.label, b.label))
  const sortedSingleItems = singleItems.sort((a, b) => collator.compare(a.label, b.label))

  // PRIMERO Dashboard, LUEGO los subgrupos, DESPUÉS los items sueltos
  const result = []
  if (dashboard) result.push(dashboard)
  result.push(...sortedSubgroups, ...sortedSingleItems)
  return result
}

// Computed para items filtrados y ordenados
const filteredItems = computed(() => {
  const filtered = filterMenuItems(menuItems, searchQuery.value)
  return sortMenu(filtered)
})

// Método para limpiar búsqueda
const clearSearch = () => {
  searchQuery.value = ''
}

// Método para manejar cambios en búsqueda
const handleSearch = () => {
  // La reactividad se encarga automáticamente del filtrado
}
</script>

<style scoped>
/* Handle de redimensionamiento */
.sidebar-resize-handle {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  width: 6px;
  cursor: ew-resize;
  background: transparent;
  z-index: 100;
  transition: background-color 0.2s ease;
}

.sidebar-resize-handle:hover {
  background: var(--gov-orange);
  opacity: 0.5;
}

.sidebar-resize-handle::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 3px;
  height: 40px;
  background: var(--slate-300);
  border-radius: 2px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.sidebar-resize-handle:hover::after {
  opacity: 1;
}

.sidebar-search {
  padding: 0.75rem;
  border-bottom: 1px solid var(--slate-200);
  background: var(--slate-50);
  position: sticky;
  top: 0;
  z-index: 10;
}

.search-input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 0.75rem;
  color: var(--slate-400);
  font-size: 0.875rem;
  pointer-events: none;
}

.search-input {
  width: 100%;
  padding: 0.5rem 2.25rem 0.5rem 2.25rem;
  border: 1px solid var(--slate-300);
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  font-family: var(--font-municipal);
  transition: all var(--transition-fast);
  background: white;
}

.search-input:focus {
  outline: none;
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
}

.search-input::placeholder {
  color: var(--slate-400);
}

.search-clear {
  position: absolute;
  right: 0.5rem;
  background: none;
  border: none;
  color: var(--slate-400);
  cursor: pointer;
  padding: 0.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-sm);
  transition: all var(--transition-fast);
}

.search-clear:hover {
  color: var(--municipal-danger);
  background: var(--slate-100);
}

.search-no-results {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem;
  margin-top: 0.5rem;
  background: white;
  border-radius: var(--radius-md);
  color: var(--slate-500);
  font-size: 0.875rem;
  border: 1px solid var(--slate-200);
}

.search-no-results svg {
  color: var(--slate-400);
}
</style>
