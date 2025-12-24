<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-signature" />
      </div>
      <div class="module-view-info">
        <h1>Bonificaciones Especiales con Oficio</h1>
        <p>Cementerios - Gestión de bonificaciones especiales autorizadas por oficio</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click.stop="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click.stop="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de Oficio/Año/Recaudadora -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="file-invoice" />
        Buscar por Oficio
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Número de Oficio</label>
            <input
              v-model.number="busqueda.oficio"
              type="number"
              class="municipal-form-control"
              min="1"
              autofocus
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Año</label>
            <input
              v-model.number="busqueda.axo"
              type="number"
              class="municipal-form-control"
              :min="2000"
              :max="new Date().getFullYear()"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Recaudadora</label>
            <select
              v-model.number="busqueda.id_rec"
              class="municipal-form-control"
            >
              <option value="">Seleccione...</option>
              <option
                v-for="rec in recaudadoras"
                :key="rec.id_rec"
                :value="rec.id_rec"
              >
                {{ rec.recaudadora }}
              </option>
            </select>
          </div>
        </div>
        <div class="form-actions">
          <button @click.stop="buscarPorOficio" class="btn-municipal-primary">
            <font-awesome-icon icon="search" />
            Buscar Oficio
          </button>
          <button @click.stop="limpiar" class="btn-municipal-secondary">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Búsqueda de Folio (solo si no existe bonificación) -->
    <div v-if="modoNuevo" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Buscar Folio
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label required">Número de Folio</label>
            <input
              v-model.number="folioABuscar"
              type="number"
              class="municipal-form-control"
              @keyup.enter="buscarFolio"
            />
          </div>
          <div class="form-actions">
            <button @click.stop="buscarFolio" class="btn-municipal-primary">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información del Folio -->
    <div v-if="folio" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="info-circle" />
        Información del Folio {{ folio.control_rcm }}
      </div>
      <div class="municipal-card-body">
        <div class="info-grid">
          <div class="info-item">
            <label class="info-label">Titular:</label>
            <span class="info-value">{{ folio.nombre }}</span>
          </div>
          <div class="info-item">
            <label class="info-label">Cementerio:</label>
            <span class="info-value">{{ folio.nombre_cementerio }}</span>
          </div>
          <div class="info-item">
            <label class="info-label">Ubicación:</label>
            <span class="info-value">{{ formatearUbicacion(folio) }}</span>
          </div>
          <div class="info-item">
            <label class="info-label">Año Pagado:</label>
            <span class="info-value text-primary fw-bold">{{ folio.axo_pagado }}</span>
          </div>
          <div class="info-item">
            <label class="info-label">Metros:</label>
            <span class="info-value">{{ folio.metros }} m²</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Formulario de Bonificación -->
    <div v-if="folio" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="percentage" />
        {{ bonificacionExistente ? 'Modificar' : 'Aplicar' }} Bonificación Especial
      </div>
      <div class="municipal-card-body">
        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Fecha del Oficio</label>
            <input
              v-model="bonificacion.fecha_ofic"
              type="date"
              class="municipal-form-control"
            />
          </div>
          <div class="form-group">
            <label class="form-label required">Importe a Bonificar</label>
            <input
              v-model.number="bonificacion.importe_bonificar"
              type="number"
              class="municipal-form-control"
              min="0"
              step="0.01"
              @blur="calcularResto"
            />
          </div>
          <div class="form-group">
            <label class="form-label">Importe Bonificado</label>
            <input
              v-model.number="bonificacion.importe_bonificado"
              type="number"
              class="municipal-form-control"
              min="0"
              step="0.01"
              @blur="calcularResto"
            />
          </div>
          <div class="form-group">
            <label class="form-label">Importe Restante</label>
            <input
              v-model.number="bonificacion.importe_resto"
              type="number"
              class="municipal-form-control"
              min="0"
              step="0.01"
              readonly
            />
          </div>
        </div>
        <div class="form-actions">
          <button @click.stop="guardarBonificacion" class="btn-municipal-primary">
            <font-awesome-icon icon="save" />
            {{ bonificacionExistente ? 'Actualizar' : 'Aplicar' }} Bonificación
          </button>
          <button
            v-if="bonificacionExistente"
            @click.stop="confirmarEliminar"
            class="btn-municipal-danger"
          >
            <font-awesome-icon icon="trash" />
            Eliminar Bonificación
          </button>
          <button @click.stop="cancelar" class="btn-municipal-secondary">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'Bonificacion1'"
      :moduleName="'cementerios'"
      :docType="docType"
      :title="'Bonificaciones Especiales con Oficio'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Estado
const recaudadoras = ref([])
const folioABuscar = ref(null)
const folio = ref(null)
const bonificacionExistente = ref(false)
const modoNuevo = ref(false)
const selectedRow = ref(null)
const hasSearched = ref(false)

const busqueda = reactive({
  oficio: null,
  axo: new Date().getFullYear(),
  id_rec: ''
})

const bonificacion = reactive({
  fecha_ofic: new Date().toISOString().split('T')[0],
  importe_bonificar: 0,
  importe_bonificado: 0,
  importe_resto: 0
})

onMounted(async () => {
  await cargarRecaudadoras()
})

const cargarRecaudadoras = async () => {
  try {
    /* TODO FUTURO: Query SQL original (Bonificacion1.dfm líneas 1812-1813):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from ta_12_recaudadoras where id_rec<8'
    */
    //Tabla ta_12_recaudadoras no existe en DB Cementerio- apunta a padron_licencias/comun
    const response = await execute(
      'sp_bonificacion1_listar_recaudadoras',
      'cementerio',
      [],
      'function',
      null,
      'public'
    )
    if(response?.result?.length > 0) {
      recaudadoras.value = response.result
    }

  } catch (error) {
    console.error('Error al cargar recaudadoras:', error)
    showToast('error', 'Error al cargar recaudadoras: ' + error.message)
  }
}

const buscarPorOficio = async () => {
  if (!busqueda.oficio || !busqueda.axo || !busqueda.id_rec) {
    showToast('warning', 'Complete todos los campos: Oficio, Año y Recaudadora')
    return
  }

  showLoading('Buscando bonificación...', 'Por favor espere')
  hasSearched.value = true
  selectedRow.value = null

  try {
    /* TODO FUTURO: Query SQL original (Bonificacion1.dfm líneas 1617-1620):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select * from ta_13_bonifica where oficio=:ofic and axo=:vaxo and id_rec=:reca'
    -- Parámetros Pascal (líneas 315-317):
    --   :ofic = StrToInt(mxFlatFloatEOficio.Text)
    --   :vaxo = StrToInt(FlatSpinEditIAxo.Text)
    --   :reca = Qryrecid_rec.Value
    */
    // La tabla ta_13_bonifica no tiene registros

    const response = await execute(
      'sp_bonificacion1_buscar_bonificacion',
      'cementerio',
      [
        { nombre: 'p_oficio', valor: busqueda.oficio, tipo: 'integer' },
        { nombre: 'p_axo', valor: busqueda.axo, tipo: 'smallint' },
        { nombre: 'p_id_rec', valor: busqueda.id_rec, tipo: 'integer' }
      ],
      'function',
      null,
      'public'
    )

    if (response && response.length > 0) {
      // Bonificación existe - Modo edición
      bonificacionExistente.value = true
      modoNuevo.value = false

      const bon = response[0]
      await buscarFolioPorId(bon.control_rcm)

      bonificacion.fecha_ofic = bon.fecha_ofic
      bonificacion.importe_bonificar = bon.importe_bonificar
      bonificacion.importe_bonificado = bon.importe_bonificado
      bonificacion.importe_resto = bon.importe_resto

      showToast('success', 'Bonificación encontrada - Modo edición')
    } else {
      // No existe - Modo nuevo
      bonificacionExistente.value = false
      modoNuevo.value = true
      folio.value = null
      folioABuscar.value = null

      bonificacion.fecha_ofic = new Date().toISOString().split('T')[0]
      bonificacion.importe_bonificar = 0
      bonificacion.importe_bonificado = 0
      bonificacion.importe_resto = 0

      showToast('info', 'Oficio no encontrado - Busque un folio para crear la bonificación')
    }
  } catch (error) {
    console.error('Error al buscar oficio:', error)
    showToast('error', 'Error al buscar oficio: ' + error.message)
  } finally {
    hideLoading()
  }
}

const buscarFolio = async () => {
  if (!folioABuscar.value) {
    showToast('warning', 'Ingrese un número de folio')
    return
  }

  showLoading('Buscando folio...', 'Por favor espere')
  selectedRow.value = null

  try {
    /* TODO FUTURO: Query SQL original (Bonificacion1.dfm líneas 1496-1498):
    -- DatabaseName: 'ingresosifx'
    -- SQL: 'select a.*, b.nombre from ta_13_datosrcm a, tc_13_cementerios b
    --       where a.control_rcm=:control and a.cementerio=b.cementerio'
    -- Parámetro Pascal (línea 259):
    --   :control = StrToInt(sCurrencyEfolio.Text)
    --NO EXISTE TABLA tc_13_cementerios EN DB CEMENTERIO ni padron_licencias/comun
    */

    const response = await execute(
      'sp_bonificacion1_buscar_folio',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: folioABuscar.value, tipo: 'integer' }
      ],
      'function',
      null,
      'public'
    )

    if (response && response.length > 0) {
      folio.value = response[0]
      showToast('success', 'Folio encontrado')
    } else {
      folio.value = null
      showToast('warning', 'No existe registro con ese folio')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    showToast('error', 'Error al buscar folio: ' + error.message)
    folio.value = null
  } finally {
    hideLoading()
  }
}

const buscarFolioPorId = async (controlRcm) => {
  showLoading('Cargando datos del folio...', 'Por favor espere')

  try {
    // Tabla tc_13_cementerios no existe en DB Cementerio ni padron_licencias/comun

    const response = await execute(
      'sp_bonificacion1_buscar_folio',
      'cementerio',
      [
        { nombre: 'p_control_rcm', valor: controlRcm, tipo: 'integer' }
      ],
      'function',
      null,
      'public'
    )

    if (response && response.length > 0) {
      folio.value = response[0]
    } else {
      folio.value = null
      showToast('error', 'Error: No se encontró el folio asociado a la bonificación')
    }
  } catch (error) {
    console.error('Error al buscar folio:', error)
    folio.value = null
  } finally {
    hideLoading()
  }
}

const calcularResto = () => {
  bonificacion.importe_resto = bonificacion.importe_bonificar - bonificacion.importe_bonificado
}

const guardarBonificacion = async () => {
  if (!folio.value) {
    showToast('warning', 'Debe buscar un folio primero')
    return
  }

  if (!bonificacion.fecha_ofic) {
    showToast('warning', 'Ingrese la fecha del oficio')
    return
  }

  if (bonificacion.importe_bonificar <= 0) {
    showToast('warning', 'El importe a bonificar debe ser mayor a cero')
    return
  }

  showLoading('Guardando bonificación...', 'Por favor espere')

  try {
    if (bonificacionExistente.value) {
      /* TODO FUTURO: Query SQL original (Bonificacion1.pas líneas 204-208):
      -- SQL: 'update ta_13_bonifrcm set
      --       fecha_ofic=fecha, importe_bonificar=valor,
      --       importe_bonificado=valor, importe_resto=valor,
      --       usuario=valor, fecha_mov=today
      --       where oficio=valor and axo=valor and id_rec=valor'
      */
      // sp no existe en tabla propiedad   id_rec
      const response = await execute(
        'sp_bonificacion1_actualizar',
        'cementerio',
        [
          { nombre: 'p_oficio', valor: busqueda.oficio, tipo: 'integer' },
          { nombre: 'p_axo', valor: busqueda.axo, tipo: 'smallint' },
          { nombre: 'p_id_rec', valor: busqueda.id_rec, tipo: 'integer' },
          { nombre: 'p_fecha_ofic', valor: bonificacion.fecha_ofic, tipo: 'date' },
          { nombre: 'p_importe_bonificar', valor: bonificacion.importe_bonificar, tipo: 'numeric' },
          { nombre: 'p_importe_bonificado', valor: bonificacion.importe_bonificado, tipo: 'numeric' },
          { nombre: 'p_importe_resto', valor: bonificacion.importe_resto, tipo: 'numeric' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
        ],
        'function',
        null,
        'public'
      )

      showToast('success', 'Bonificación actualizada exitosamente')
    } else {
      /* TODO FUTURO: Query SQL original (Bonificacion1.pas líneas 169-177):
      -- SQL: 'insert into ta_13_bonifrcm values(0,
      --       oficio, axo, id_rec, null,
      --       control_rcm, cementerio, clase, clase_alfa,
      --       seccion, seccion_alfa, linea, linea_alfa,
      --       fosa, fosa_alfa,
      --       fecha_ofic, importe_bonificar, importe_bonificado,
      --       importe_resto, usuario, today)'
      */

      const response = await execute(
        'sp_bonificacion1_insertar',
        'cementerio',
        [
          { nombre: 'p_oficio', valor: busqueda.oficio, tipo: 'integer' },
          { nombre: 'p_axo', valor: busqueda.axo, tipo: 'smallint' },
          { nombre: 'p_id_rec', valor: busqueda.id_rec, tipo: 'integer' },
          { nombre: 'p_control_rcm', valor: folio.value.control_rcm, tipo: 'integer' },
          { nombre: 'p_cementerio', valor: folio.value.cementerio, tipo: 'varchar' },
          { nombre: 'p_clase', valor: folio.value.clase, tipo: 'smallint' },
          { nombre: 'p_clase_alfa', valor: folio.value.clase_alfa || '', tipo: 'varchar' },
          { nombre: 'p_seccion', valor: folio.value.seccion, tipo: 'smallint' },
          { nombre: 'p_seccion_alfa', valor: folio.value.seccion_alfa || '', tipo: 'varchar' },
          { nombre: 'p_linea', valor: folio.value.linea, tipo: 'smallint' },
          { nombre: 'p_linea_alfa', valor: folio.value.linea_alfa || '', tipo: 'varchar' },
          { nombre: 'p_fosa', valor: folio.value.fosa, tipo: 'smallint' },
          { nombre: 'p_fosa_alfa', valor: folio.value.fosa_alfa || '', tipo: 'varchar' },
          { nombre: 'p_fecha_ofic', valor: bonificacion.fecha_ofic, tipo: 'date' },
          { nombre: 'p_importe_bonificar', valor: bonificacion.importe_bonificar, tipo: 'numeric' },
          { nombre: 'p_importe_bonificado', valor: bonificacion.importe_bonificado, tipo: 'numeric' },
          { nombre: 'p_importe_resto', valor: bonificacion.importe_resto, tipo: 'numeric' },
          { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
        ],
        'function',
        null,
        'public'
      )

      showToast('success', 'Bonificación aplicada exitosamente')
    }

    limpiar()
  } catch (error) {
    console.error('Error al guardar bonificación:', error)
    showToast('error', 'Error al guardar bonificación: ' + error.message)
  } finally {
    hideLoading()
  }
}

const confirmarEliminar = async () => {
  const result = await Swal.fire({
    title: '¿Eliminar bonificación?',
    text: 'Esta acción no se puede deshacer',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await eliminarBonificacion()
  }
}

const eliminarBonificacion = async () => {
  showLoading('Eliminando bonificación...', 'Por favor espere')

  try {
    /* TODO FUTURO: Query SQL original (Bonificacion1.pas líneas 233-234):
    -- SQL: 'delete from ta_13_bonifrcm
    --       where oficio=valor and axo=valor and id_rec=valor'
    */

    const response = await execute(
      'sp_bonificacion1_eliminar',
      'cementerio',
      [
        { nombre: 'p_oficio', valor: busqueda.oficio, tipo: 'integer' },
        { nombre: 'p_axo', valor: busqueda.axo, tipo: 'smallint' },
        { nombre: 'p_id_rec', valor: busqueda.id_rec, tipo: 'integer' }
      ],
      'function',
      null,
      'public'
    )

    showToast('success', 'Bonificación eliminada exitosamente')
    limpiar()
  } catch (error) {
    console.error('Error al eliminar bonificación:', error)
    showToast('error', 'Error al eliminar bonificación: ' + error.message)
  } finally {
    hideLoading()
  }
}

const cancelar = () => {
  folio.value = null
  folioABuscar.value = null
  modoNuevo.value = false
  bonificacionExistente.value = false

  bonificacion.fecha_ofic = new Date().toISOString().split('T')[0]
  bonificacion.importe_bonificar = 0
  bonificacion.importe_bonificado = 0
  bonificacion.importe_resto = 0
}

const limpiar = () => {
  busqueda.oficio = null
  busqueda.axo = new Date().getFullYear()
  busqueda.id_rec = ''
  hasSearched.value = false
  selectedRow.value = null
  cancelar()
}

const formatearUbicacion = (folio) => {
  const partes = []
  partes.push(`Cl:${folio.clase}${folio.clase_alfa || ''}`)
  partes.push(`Sec:${folio.seccion}${folio.seccion_alfa || ''}`)
  partes.push(`Lin:${folio.linea}${folio.linea_alfa || ''}`)
  partes.push(`Fosa:${folio.fosa}${folio.fosa_alfa || ''}`)
  return partes.join(' ')
}
</script>
