<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Actualización Individual de Contrato</h1>
        <p>Aseo Contratado - Modificación de datos de un contrato específico</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Búsqueda de Contrato</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4">
            <label class="municipal-form-label">Número de Contrato</label>
            <input type="text" class="municipal-form-control" v-model="numContrato"
              placeholder="Ej: 12345" @keyup.enter="buscarContrato" />
          </div>
          <div class="col-md-4">
            <label class="municipal-form-label">Cuenta Catastral</label>
            <input type="text" class="municipal-form-control" v-model="cuentaCatastral"
              placeholder="Ej: 123456789012" @keyup.enter="buscarContrato" />
          </div>
          <div class="col-md-4">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscarContrato" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar Contrato
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="contrato">
      <div class="municipal-card shadow-sm mb-4">
        <div class="municipal-card-header bg-light d-flex justify-content-between">
          <h6 class="mb-0">Contrato #{{ contrato.num_contrato }}</h6>
          <span class="badge" :class="contrato.status === 'A' ? 'bg-success' : 'bg-danger'">
            {{ contrato.status === 'A' ? 'Activo' : 'Cancelado' }}
          </span>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6">
              <p><strong>Contribuyente:</strong> {{ contrato.contribuyente }}</p>
              <p><strong>Domicilio:</strong> {{ contrato.domicilio_completo }}</p>
            </div>
            <div class="col-md-6">
              <p><strong>Zona:</strong> {{ contrato.zona }}</p>
              <p><strong>Tipo:</strong> {{ formatTipoAseoCompleto(contrato.tipo_aseo) }}</p>
            </div>
          </div>
        </div>
      </div>

      <div v-if="contrato.status === 'A'" class="municipal-card">
        <div class="municipal-card-header">
        <h5>Actualización de Datos</h5>
      </div>
        <div class="municipal-card-body">
          <ul class="nav nav-tabs mb-3" role="tablist">
            <li class="municipal-tab-item">
              <a class="municipal-tab-link" :class="{ active: tabActiva === 'ubicacion' }"
                @click.prevent="tabActiva = 'ubicacion'" href="#">
                <font-awesome-icon icon="map-marker-alt" /> Ubicación
              </a>
            </li>
            <li class="municipal-tab-item">
              <a class="municipal-tab-link" :class="{ active: tabActiva === 'servicio' }"
                @click.prevent="tabActiva = 'servicio'" href="#">
                <font-awesome-icon icon="truck" /> Servicio
              </a>
            </li>
            <li class="municipal-tab-item">
              <a class="municipal-tab-link" :class="{ active: tabActiva === 'cuota' }"
                @click.prevent="tabActiva = 'cuota'" href="#">
                <font-awesome-icon icon="dollar-sign" /> Cuota
              </a>
            </li>
            <li class="municipal-tab-item">
              <a class="municipal-tab-link" :class="{ active: tabActiva === 'contribuyente' }"
                @click.prevent="tabActiva = 'contribuyente'" href="#">
                <font-awesome-icon icon="user" /> Contribuyente
              </a>
            </li>
          </ul>

          <div class="tab-content">
            <!-- Tab Ubicación -->
            <div v-show="tabActiva === 'ubicacion'">
              <div class="row mb-3">
                <div class="col-md-3">
                  <label class="municipal-form-label">Zona</label>
                  <select class="municipal-form-control" v-model="datosEdicion.zona">
                    <option v-for="z in zonas" :key="z.ctrol_zona" :value="z.zona">
                      Zona {{ z.zona }}
                    </option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Colonia</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.colonia" />
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Referencias</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.referencias"
                    placeholder="Entre calles, puntos de referencia..." />
                </div>
              </div>
            </div>

            <!-- Tab Servicio -->
            <div v-show="tabActiva === 'servicio'">
              <div class="row mb-3">
                <div class="col-md-3">
                  <label class="municipal-form-label">Tipo de Aseo</label>
                  <select class="municipal-form-control" v-model="datosEdicion.tipo_aseo">
                    <option value="D">Doméstico</option>
                    <option value="C">Comercial</option>
                    <option value="I">Industrial</option>
                    <option value="S">Servicios</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Empresa</label>
                  <select class="municipal-form-control" v-model="datosEdicion.num_empresa">
                    <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                      {{ emp.nombre_empresa }}
                    </option>
                  </select>
                </div>
                <div class="col-md-4">
                  <label class="municipal-form-label">Unidad Recolectora</label>
                  <select class="municipal-form-control" v-model="datosEdicion.num_unidad">
                    <option value="">Sin asignar</option>
                    <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                      {{ u.nombre_unidad }}
                    </option>
                  </select>
                </div>
                <div class="col-md-2">
                  <label class="municipal-form-label">Periodo Actual</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.periodo_actual"
                    placeholder="YYYYMM" maxlength="6" />
                </div>
              </div>
            </div>

            <!-- Tab Cuota -->
            <div v-show="tabActiva === 'cuota'">
              <div class="row mb-3">
                <div class="col-md-3">
                  <label class="municipal-form-label">Cuota Mensual</label>
                  <div class="input-group">
                    <span class="input-group-text">$</span>
                    <input type="number" class="municipal-form-control" v-model.number="datosEdicion.cuota_mensual"
                      step="0.01" min="0" />
                  </div>
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Descuento (%)</label>
                  <input type="number" class="municipal-form-control" v-model.number="datosEdicion.descuento"
                    step="0.01" min="0" max="100" />
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">Observaciones de Cuota</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.observaciones_cuota"
                    placeholder="Ej: Descuento especial adulto mayor" />
                </div>
              </div>
            </div>

            <!-- Tab Contribuyente -->
            <div v-show="tabActiva === 'contribuyente'">
              <div class="row mb-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Nombre del Contribuyente</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.contribuyente" />
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">RFC</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.rfc"
                    maxlength="13" style="text-transform: uppercase;" />
                </div>
                <div class="col-md-3">
                  <label class="municipal-form-label">Teléfono</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.telefono"
                    placeholder="10 dígitos" />
                </div>
              </div>
              <div class="row mb-3">
                <div class="col-md-6">
                  <label class="municipal-form-label">Email</label>
                  <input type="email" class="municipal-form-control" v-model="datosEdicion.email"
                    placeholder="correo@ejemplo.com" />
                </div>
                <div class="col-md-6">
                  <label class="municipal-form-label">CURP</label>
                  <input type="text" class="municipal-form-control" v-model="datosEdicion.curp"
                    maxlength="18" style="text-transform: uppercase;" />
                </div>
              </div>
            </div>
          </div>

          <div class="row mt-4">
            <div class="col-md-12">
              <label class="municipal-form-label">Observaciones Generales</label>
              <textarea class="municipal-form-control" v-model="datosEdicion.observaciones" rows="3"
                placeholder="Notas adicionales sobre el contrato..."></textarea>
            </div>
          </div>

          <div class="d-flex justify-content-end mt-3">
            <button class="btn-municipal-secondary me-2" @click="cancelarEdicion">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button class="btn-municipal-primary" @click="guardarCambios" :disabled="!hayConsultarCambios()">
              <font-awesome-icon icon="save" /> Guardar Cambios
            </button>
          </div>
        </div>
      </div>

      <div v-else class="alert alert-warning">
        <font-awesome-icon icon="exclamation-triangle" class="me-2" />
        Este contrato está <strong>cancelado</strong> y no puede ser modificado.
        Solo los contratos activos pueden actualizarse.
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Actualización Individual de Contrato">
      <h6>Descripción</h6>
      <p>Permite modificar los datos de un contrato específico de manera individual.</p>
      <h6>Datos Modificables</h6>
      <ul>
        <li><strong>Ubicación:</strong> Zona, colonia, referencias</li>
        <li><strong>Servicio:</strong> Tipo de aseo, empresa, unidad recolectora, periodo</li>
        <li><strong>Cuota:</strong> Monto mensual, descuentos, observaciones de cuota</li>
        <li><strong>Contribuyente:</strong> Nombre, RFC, CURP, teléfono, email</li>
      </ul>
      <h6>Restricciones</h6>
      <p>Solo se pueden modificar contratos con status <strong>Activo</strong>.
      Los contratos cancelados no permiten modificaciones.</p>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const numContrato = ref('')
const cuentaCatastral = ref('')
const contrato = ref(null)
const contratoOriginal = ref(null)
const tabActiva = ref('ubicacion')
const zonas = ref([])
const empresas = ref([])
const unidades = ref([])

const datosEdicion = ref({
  zona: '',
  colonia: '',
  referencias: '',
  tipo_aseo: '',
  num_empresa: '',
  num_unidad: '',
  periodo_actual: '',
  cuota_mensual: 0,
  descuento: 0,
  observaciones_cuota: '',
  contribuyente: '',
  rfc: '',
  curp: '',
  telefono: '',
  email: '',
  observaciones: ''
})

const buscarContrato = async () => {
  if (!numContrato.value && !cuentaCatastral.value) {
    return showToast('Ingrese número de contrato o cuenta catastral', 'warning')
  }

  cargando.value = true
  try {
    const params = {
      p_num_contrato: numContrato.value || null,
      p_cuenta_catastral: cuentaCatastral.value || null
    }
    const response = await execute('SP_ASEO_BUSCAR_CONTRATO_INDIVIDUAL', 'aseo_contratado', params)

    if (response && response.length > 0) {
      contrato.value = response[0]
      contratoOriginal.value = JSON.parse(JSON.stringify(response[0]))
      cargarDatosEdicion()
      showToast('Contrato encontrado', 'success')
    } else {
      showToast('Contrato no encontrado', 'warning')
      contrato.value = null
    }
  } catch (error) {
    handleError(error, 'Error al buscar contrato')
  } finally {
    cargando.value = false
  }
}

const cargarDatosEdicion = () => {
  datosEdicion.value = {
    zona: contrato.value.zona || '',
    colonia: contrato.value.colonia || '',
    referencias: contrato.value.referencias || '',
    tipo_aseo: contrato.value.tipo_aseo || '',
    num_empresa: contrato.value.num_empresa || '',
    num_unidad: contrato.value.num_unidad || '',
    periodo_actual: contrato.value.periodo_actual || '',
    cuota_mensual: parseFloat(contrato.value.cuota_mensual || 0),
    descuento: parseFloat(contrato.value.descuento || 0),
    observaciones_cuota: contrato.value.observaciones_cuota || '',
    contribuyente: contrato.value.contribuyente || '',
    rfc: contrato.value.rfc || '',
    curp: contrato.value.curp || '',
    telefono: contrato.value.telefono || '',
    email: contrato.value.email || '',
    observaciones: contrato.value.observaciones || ''
  }
  tabActiva.value = 'ubicacion'
}

const hayConsultarCambios = () => {
  if (!contratoOriginal.value) return false

  return datosEdicion.value.zona !== contratoOriginal.value.zona ||
         datosEdicion.value.colonia !== contratoOriginal.value.colonia ||
         datosEdicion.value.referencias !== (contratoOriginal.value.referencias || '') ||
         datosEdicion.value.tipo_aseo !== contratoOriginal.value.tipo_aseo ||
         datosEdicion.value.num_empresa !== contratoOriginal.value.num_empresa ||
         datosEdicion.value.num_unidad !== (contratoOriginal.value.num_unidad || '') ||
         datosEdicion.value.periodo_actual !== (contratoOriginal.value.periodo_actual || '') ||
         datosEdicion.value.cuota_mensual !== parseFloat(contratoOriginal.value.cuota_mensual || 0) ||
         datosEdicion.value.descuento !== parseFloat(contratoOriginal.value.descuento || 0) ||
         datosEdicion.value.observaciones_cuota !== (contratoOriginal.value.observaciones_cuota || '') ||
         datosEdicion.value.contribuyente !== contratoOriginal.value.contribuyente ||
         datosEdicion.value.rfc !== (contratoOriginal.value.rfc || '') ||
         datosEdicion.value.curp !== (contratoOriginal.value.curp || '') ||
         datosEdicion.value.telefono !== (contratoOriginal.value.telefono || '') ||
         datosEdicion.value.email !== (contratoOriginal.value.email || '') ||
         datosEdicion.value.observaciones !== (contratoOriginal.value.observaciones || '')
}

const guardarCambios = async () => {
  const result = await Swal.fire({
    title: '¿Guardar Cambios?',
    text: 'Se actualizarán los datos del contrato',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#0d6efd',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_control_contrato: contrato.value.control_contrato,
      p_zona: datosEdicion.value.zona,
      p_colonia: datosEdicion.value.colonia,
      p_referencias: datosEdicion.value.referencias || null,
      p_tipo_aseo: datosEdicion.value.tipo_aseo,
      p_num_empresa: datosEdicion.value.num_empresa,
      p_num_unidad: datosEdicion.value.num_unidad || null,
      p_periodo_actual: datosEdicion.value.periodo_actual || null,
      p_cuota_mensual: datosEdicion.value.cuota_mensual,
      p_descuento: datosEdicion.value.descuento,
      p_observaciones_cuota: datosEdicion.value.observaciones_cuota || null,
      p_contribuyente: datosEdicion.value.contribuyente,
      p_rfc: datosEdicion.value.rfc || null,
      p_curp: datosEdicion.value.curp || null,
      p_telefono: datosEdicion.value.telefono || null,
      p_email: datosEdicion.value.email || null,
      p_observaciones: datosEdicion.value.observaciones || null
    }

    await execute('SP_ASEO_ACTUALIZAR_CONTRATO_INDIVIDUAL', 'aseo_contratado', params)

    await Swal.fire('¡Guardado!', 'Los cambios han sido guardados correctamente', 'success')

    await buscarContrato()
  } catch (error) {
    handleError(error, 'Error al guardar cambios')
  } finally {
    cargando.value = false
  }
}

const cancelarEdicion = () => {
  if (contratoOriginal.value) {
    cargarDatosEdicion()
    showToast('Cambios descartados', 'info')
  }
}

const formatTipoAseoCompleto = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

onMounted(async () => {
  try {
    const [respZonas, respEmpresas, respUnidades] = await Promise.all([
      execute('SP_ASEO_ZONAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {})
    ])
    zonas.value = respZonas || []
    empresas.value = respEmpresas || []
    unidades.value = respUnidades || []
  } catch (error) {
    console.error('Error al cargar catálogos:', error)
  }
})
</script>

