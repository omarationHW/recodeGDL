<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Cancelacion de Contratos</h1>
        <p>Aseo Contratado - Cancelacion de contratos con detalle de adeudos</p>
      </div>
      <button type="button" class="btn-help-icon" @click="showDocumentation = true" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Busqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="search-form-inline">
            <div class="search-field">
              <label class="municipal-form-label required">No. Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Ej: 12345"
                @keyup.enter="buscarContrato"
              />
            </div>
            <div class="search-field search-field-large">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="ctrolAseo" class="municipal-form-control">
                <option value="">-- Seleccione tipo de aseo --</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.display_text }}
                </option>
              </select>
            </div>
            <div class="search-field-button">
              <button type="button" class="btn-municipal-primary" @click="buscarContrato">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Contrato -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-alt" /> Datos del Contrato</h5>
          <span class="municipal-badge" :class="getBadgeClass(contrato.status_contrato)">
            {{ contrato.status_contrato }}
          </span>
        </div>
        <div class="municipal-card-body">
          <!-- Info Principal -->
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Control Contrato</span>
              <span class="info-value info-value-highlight">{{ contrato.control_contrato }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">No. Contrato</span>
              <span class="info-value info-value-highlight">{{ contrato.num_contrato }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Tipo Aseo</span>
              <span class="info-value">{{ contrato.tipo_aseo }} - {{ contrato.tipo_aseo_descripcion }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">Cantidad Recolec.</span>
              <span class="info-value">{{ contrato.cantidad_recoleccion }}</span>
            </div>
          </div>

          <!-- Ubicacion -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="map-marker-alt" /> Ubicacion</h6>
            <div class="info-grid">
              <div class="info-item info-item-wide">
                <span class="info-label">Domicilio</span>
                <span class="info-value">{{ contrato.calle || '-' }}</span>
              </div>
              <div class="info-item">
                <span class="info-label">Sector</span>
                <span class="info-value">{{ contrato.sector || '-' }}</span>
              </div>
            </div>
          </div>

          <!-- Empresa -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="building" /> Empresa</h6>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">No. Empresa</span>
                <span class="info-value">{{ contrato.num_empresa }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Nombre</span>
                <span class="info-value">{{ contrato.nombre_empresa || '-' }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Representante</span>
                <span class="info-value">{{ contrato.representante_empresa || '-' }}</span>
              </div>
            </div>
          </div>

          <!-- Recoleccion -->
          <div class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="truck" /> Recoleccion</h6>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">Cve. Recoleccion</span>
                <span class="info-value">{{ contrato.cve_recoleccion || '-' }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Unidad Recoleccion</span>
                <span class="info-value">{{ contrato.unidad_recoleccion || '-' }}</span>
              </div>
            </div>
          </div>

          <!-- Convenio si existe -->
          <div v-if="infoConvenio" class="mt-3">
            <div class="municipal-alert municipal-alert-info">
              <font-awesome-icon icon="file-signature" />
              <div>
                <strong>Contrato Conveniado</strong>
                <p class="mb-0">Convenio: {{ infoConvenio.convenio }}</p>
              </div>
            </div>
          </div>

          <!-- Licencia si existe -->
          <div v-if="infoLicencia" class="info-section">
            <h6 class="info-section-title"><font-awesome-icon icon="id-card" /> Licencia Asociada</h6>
            <div class="info-grid">
              <div class="info-item">
                <span class="info-label">No. Licencia</span>
                <span class="info-value">{{ infoLicencia.num_licencia }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Actividad</span>
                <span class="info-value">{{ infoLicencia.actividad }}</span>
              </div>
              <div class="info-item info-item-wide">
                <span class="info-label">Propietario</span>
                <span class="info-value">{{ infoLicencia.propietario }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos del Contrato -->
      <div v-if="contratoEncontrado && adeudos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header municipal-card-header-warning">
          <h5><font-awesome-icon icon="money-bill-wave" /> Adeudos del Contrato</h5>
          <span class="municipal-badge municipal-badge-danger">{{ adeudos.length }} periodos</span>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Periodo</th>
                  <th>Concepto</th>
                  <th>Cant.</th>
                  <th class="text-right">Adeudos</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Multa</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Actualiz.</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, idx) in adeudos" :key="idx">
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ adeudo.concepto }}</td>
                  <td class="text-center">{{ adeudo.cant_recolec }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_adeudos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_multa) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_gastos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.actualizacion) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(calcularTotalAdeudo(adeudo)) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-footer-total">
                  <td colspan="3"><strong>TOTAL</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.adeudos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.recargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.multa) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.gastos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.actualizacion) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.total) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Panel de Cancelacion -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-header municipal-card-header-danger">
          <h5><font-awesome-icon icon="ban" /> Datos para la Cancelacion</h5>
        </div>
        <div class="municipal-card-body">
          <div class="baja-form">
            <!-- Periodo -->
            <div class="baja-form-row">
              <div class="baja-form-field">
                <label class="municipal-form-label required">Anio</label>
                <input
                  type="number"
                  v-model.number="datosCancel.anio"
                  class="municipal-form-control"
                  :min="1990"
                  :max="ejercicioActual"
                />
              </div>
              <div class="baja-form-field">
                <label class="municipal-form-label required">Mes</label>
                <select v-model="datosCancel.mes" class="municipal-form-control">
                  <option value="01">01 - Enero</option>
                  <option value="02">02 - Febrero</option>
                  <option value="03">03 - Marzo</option>
                  <option value="04">04 - Abril</option>
                  <option value="05">05 - Mayo</option>
                  <option value="06">06 - Junio</option>
                  <option value="07">07 - Julio</option>
                  <option value="08">08 - Agosto</option>
                  <option value="09">09 - Septiembre</option>
                  <option value="10">10 - Octubre</option>
                  <option value="11">11 - Noviembre</option>
                  <option value="12">12 - Diciembre</option>
                </select>
              </div>
              <div class="baja-form-field">
                <label class="municipal-form-label required">Fecha de Baja</label>
                <input
                  type="date"
                  v-model="datosCancel.fechaBaja"
                  class="municipal-form-control"
                  :max="fechaHoy"
                />
              </div>
            </div>

            <!-- Documento y Descripcion -->
            <div class="baja-form-row">
              <div class="baja-form-field">
                <label class="municipal-form-label required">Documento (min 10 caracteres)</label>
                <input
                  type="text"
                  v-model="datosCancel.documento"
                  class="municipal-form-control"
                  maxlength="100"
                  placeholder="Numero de documento que avala la cancelacion"
                />
                <small class="field-counter">{{ datosCancel.documento.length }}/100</small>
              </div>
              <div class="baja-form-field baja-form-field-wide">
                <label class="municipal-form-label required">Descripcion (min 10 caracteres)</label>
                <textarea
                  v-model="datosCancel.descripcion"
                  class="municipal-form-control"
                  rows="3"
                  maxlength="500"
                  placeholder="Descripcion detallada del motivo de la cancelacion"
                ></textarea>
                <small class="field-counter">{{ datosCancel.descripcion.length }}/500</small>
              </div>
            </div>
          </div>

          <!-- Errores -->
          <div v-if="erroresValidacion.length > 0" class="municipal-alert municipal-alert-danger mt-3">
            <font-awesome-icon icon="exclamation-circle" />
            <div>
              <strong>Corrija los siguientes errores:</strong>
              <ul class="error-list">
                <li v-for="(error, idx) in erroresValidacion" :key="idx">{{ error }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Botones -->
      <div v-if="contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              type="button"
              class="btn-municipal-danger"
              @click="ejecutarCancelacion"
              :disabled="!isFormValid"
            >
              <font-awesome-icon icon="ban" /> Cancelar Contrato
            </button>
            <button type="button" class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="times" /> Limpiar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="salir">
              <font-awesome-icon icon="door-open" /> Salir
            </button>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body">
          <div class="empty-state">
            <font-awesome-icon icon="search" class="empty-state-icon" />
            <h4>No se encontro el contrato</h4>
            <p>No existe contrato con el numero y tipo de aseo especificados.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentation"
      @close="showDocumentation = false"
      title="Ayuda - Cancelacion de Contratos"
      componentName="Contratos_Cancela"
    >
      <h3>Cancelacion de Contratos</h3>
      <p>Este modulo permite cancelar contratos de aseo contratado mostrando el detalle completo de adeudos.</p>

      <h4>Procedimiento:</h4>
      <ol>
        <li>Ingrese el numero de contrato y seleccione el tipo de aseo</li>
        <li>Presione Buscar</li>
        <li>Revise la informacion del contrato y los adeudos pendientes</li>
        <li>Ingrese el periodo de cancelacion (Anio y Mes)</li>
        <li>Ingrese la fecha de baja</li>
        <li>Ingrese el documento que avala la cancelacion (minimo 10 caracteres)</li>
        <li>Ingrese la descripcion del motivo (minimo 10 caracteres)</li>
        <li>Presione Cancelar Contrato</li>
      </ol>

      <h4>Diferencia con Baja de Contratos:</h4>
      <p>Este modulo muestra informacion mas detallada del contrato incluyendo:</p>
      <ul>
        <li>Datos completos del domicilio</li>
        <li>Informacion de RFC y CURP</li>
        <li>Detalle de adeudos por periodo</li>
        <li>Licencias asociadas al contrato</li>
        <li>Convenios existentes</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const router = useRouter()

// Estado
const showDocumentation = ref(false)
const tiposAseo = ref([])
const numContrato = ref(null)
const ctrolAseo = ref('')
const contratoEncontrado = ref(false)
const busquedaRealizada = ref(false)
const contrato = ref({})
const adeudos = ref([])
const infoConvenio = ref(null)
const infoLicencia = ref(null)

// Ejercicio actual y fecha
const ejercicioActual = new Date().getFullYear()
const fechaHoy = new Date().toISOString().split('T')[0]

// Datos de cancelacion
const datosCancel = ref({
  anio: ejercicioActual,
  mes: '12',
  fechaBaja: fechaHoy,
  documento: '',
  descripcion: ''
})

// Totales de adeudos
const totales = computed(() => {
  return adeudos.value.reduce((acc, a) => {
    acc.adeudos += parseFloat(a.importe_adeudos || 0)
    acc.recargos += parseFloat(a.importe_recargos || 0)
    acc.multa += parseFloat(a.importe_multa || 0)
    acc.gastos += parseFloat(a.importe_gastos || 0)
    acc.actualizacion += parseFloat(a.actualizacion || 0)
    acc.total += calcularTotalAdeudo(a)
    return acc
  }, { adeudos: 0, recargos: 0, multa: 0, gastos: 0, actualizacion: 0, total: 0 })
})

// Calcular total de un adeudo
const calcularTotalAdeudo = (adeudo) => {
  return parseFloat(adeudo.importe_adeudos || 0) +
         parseFloat(adeudo.importe_recargos || 0) +
         parseFloat(adeudo.importe_multa || 0) +
         parseFloat(adeudo.importe_gastos || 0) +
         parseFloat(adeudo.actualizacion || 0)
}

// Errores de validacion
const erroresValidacion = computed(() => {
  const errores = []
  if (datosCancel.value.documento.trim().length < 10) {
    errores.push('El Documento debe tener al menos 10 caracteres')
  }
  if (datosCancel.value.descripcion.trim().length < 10) {
    errores.push('La Descripcion debe tener al menos 10 caracteres')
  }
  if (!datosCancel.value.fechaBaja) {
    errores.push('La Fecha de Baja es requerida')
  }
  if (!datosCancel.value.anio) {
    errores.push('El Anio es requerido')
  }
  return errores
})

// Validacion del formulario
const isFormValid = computed(() => {
  return erroresValidacion.value.length === 0
})

// Formatear moneda
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0)
}

// Badge class
const getBadgeClass = (status) => {
  if (status === 'VIGENTE' || status === 'V') return 'municipal-badge-success'
  if (status === 'CANCELADO' || status === 'C') return 'municipal-badge-danger'
  return 'municipal-badge-secondary'
}

// Cargar tipos de aseo
const cargarTiposAseo = async () => {
  try {
    const data = await execute('sp_aseo_tipos_aseo_combo', BASE_DB, [], '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      tiposAseo.value = data
      if (data.length >= 3) {
        ctrolAseo.value = data[2].ctrol_aseo
      }
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cargar tipos de aseo')
  }
}

// Buscar contrato
const buscarContrato = async () => {
  if (!numContrato.value || numContrato.value === 0) {
    showToast('Ingrese un numero de contrato', 'warning')
    return
  }
  if (!ctrolAseo.value) {
    showToast('Seleccione un tipo de aseo', 'warning')
    return
  }

  showLoading()
  busquedaRealizada.value = true
  contratoEncontrado.value = false
  adeudos.value = []
  infoConvenio.value = null
  infoLicencia.value = null

  try {
    // Buscar contrato usando sp_aseo_buscar_contrato_baja (mismo que Contratos_Baja)
    const params = [
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: ctrolAseo.value, tipo: 'integer' }
    ]

    const data = await execute('sp_aseo_buscar_contrato_baja', BASE_DB, params, '', null, SCHEMA)

    if (data && data.length > 0) {
      const resultado = data[0]

      // Mapear campos para compatibilidad con el template
      contrato.value = {
        control_contrato: resultado.control_contrato,
        num_contrato: resultado.num_contrato,
        calle: resultado.domicilio || '',
        numext: '',
        numint: '',
        colonia: '',
        sector: resultado.sector || '',
        cp: '',
        rfc: '',
        municipio: 'GUADALAJARA',
        estado: 'JALISCO',
        curp: '',
        status_contrato: resultado.status_vigencia === 'V' ? 'VIGENTE' :
                         resultado.status_vigencia === 'C' ? 'CANCELADO' :
                         resultado.status_vigencia === 'N' ? 'CONVENIADO' :
                         resultado.status_vigencia === 'S' ? 'SUSPENDIDO' : resultado.status_vigencia,
        num_empresa: resultado.num_empresa,
        nombre_empresa: resultado.nombre_empresa || '',
        representante_empresa: resultado.representante || '',
        tipo_aseo: resultado.tipo_aseo || '',
        tipo_aseo_descripcion: resultado.descripcion_aseo || '',
        cve_recoleccion: resultado.cve_recolec || '',
        unidad_recoleccion: resultado.descripcion_recolec || '',
        cantidad_recoleccion: resultado.cantidad_recolec || 0
      }
      contratoEncontrado.value = true

      // Cargar adeudos (usa control_contrato, no num_contrato)
      const tipoAseoLetra = tiposAseo.value.find(t => t.ctrol_aseo === ctrolAseo.value)?.tipo_aseo || ''
      await cargarAdeudos(resultado.control_contrato, tipoAseoLetra)

      // Buscar convenio
      await buscarConvenio(resultado.control_contrato)

      // Buscar licencia
      await buscarLicencia(resultado.control_contrato)

    } else {
      hideLoading()
      showToast('No se encontro contrato con esos datos', 'warning')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar contrato')
  } finally {
    hideLoading()
  }
}

// Cargar adeudos
const cargarAdeudos = async (controlContrato, tipoAseo) => {
  try {
    const refPeriodo = `${ejercicioActual}-12`
    const params = [
      { nombre: 'p_tipo', valor: tipoAseo, tipo: 'string' },
      { nombre: 'p_numero', valor: controlContrato, tipo: 'integer' },
      { nombre: 'p_rep', valor: 'V', tipo: 'string' },
      { nombre: 'pref', valor: refPeriodo, tipo: 'string' }
    ]

    const data = await execute('sp16_adeudos_f02', BASE_DB, params, '', null, SCHEMA)
    if (data && Array.isArray(data)) {
      adeudos.value = data
    }
  } catch (error) {
    hideLoading()
    // Si falla, continuar sin adeudos
    console.error('Error al cargar adeudos:', error)
  }
}

// Buscar convenio
const buscarConvenio = async (controlContrato) => {
  try {
    const params = [
      { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_buscar_convenio_contrato', BASE_DB, params, '', null, SCHEMA)
    if (data && data.length > 0) {
      infoConvenio.value = data[0]
    }
  } catch (error) {
    hideLoading()
    // Sin convenio
  }
}

// Buscar licencia
const buscarLicencia = async (controlContrato) => {
  try {
    const params = [
      { nombre: 'p_control_contrato', valor: controlContrato, tipo: 'integer' }
    ]
    const data = await execute('sp_aseo_buscar_licencia_contrato', BASE_DB, params, '', null, SCHEMA)
    if (data && data.length > 0) {
      infoLicencia.value = data[0]
    }
  } catch (error) {
    hideLoading()
    // Sin licencia
  }
}

// Ejecutar cancelacion
const ejecutarCancelacion = async () => {
  if (!isFormValid.value) {
    showToast('Corrija los errores antes de continuar', 'warning')
    return
  }

  const result = await Swal.fire({
    title: 'Confirmar Cancelacion',
    html: `
      <div style="text-align: left; padding: 1rem 0;">
        <p><strong>Contrato:</strong> ${contrato.value.num_contrato}</p>
        <p><strong>Tipo Aseo:</strong> ${contrato.value.tipo_aseo} - ${contrato.value.tipo_aseo_descripcion}</p>
        <p><strong>Periodo cancelacion:</strong> ${datosCancel.value.anio}-${datosCancel.value.mes}</p>
        ${adeudos.value.length > 0 ? `<p class="text-warning"><strong>Adeudos pendientes:</strong> ${adeudos.value.length} periodos por $${formatCurrency(totales.value.total)}</p>` : ''}
        <p style="color: #dc3545; margin-top: 1rem;"><strong>Esta accion no se puede deshacer.</strong></p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Si, cancelar contrato',
    cancelButtonText: 'No, volver',
    confirmButtonColor: '#dc3545'
  })

  if (!result.isConfirmed) {
    showToast('Operacion cancelada', 'info')
    return
  }

  showLoading()
  try {
    const periodo = `${datosCancel.value.anio}-${datosCancel.value.mes}`
    const params = [
      { nombre: 'p_control_contrato', valor: contrato.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_fecha_canc', valor: datosCancel.value.fechaBaja, tipo: 'string' },
      { nombre: 'p_periodo', valor: periodo, tipo: 'string' },
      { nombre: 'p_docto', valor: datosCancel.value.documento.trim(), tipo: 'string' },
      { nombre: 'p_descrip', valor: datosCancel.value.descripcion.trim(), tipo: 'string' }
    ]

    const data = await execute('sp16_cancela_contrato', BASE_DB, params, '', null, SCHEMA)
    hideLoading()

    if (data && data.length > 0) {
      if (data[0].status === 0) {
        await Swal.fire({
          title: 'Cancelacion Exitosa',
          text: data[0].leyenda,
          icon: 'success'
        })
        limpiar()
      } else {
        await Swal.fire({
          title: 'Error',
          text: data[0].leyenda || 'Ocurrio un error al procesar la cancelacion',
          icon: 'error'
        })
      }
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al cancelar el contrato')
  }
}

// Limpiar
const limpiar = () => {
  numContrato.value = null
  contratoEncontrado.value = false
  busquedaRealizada.value = false
  contrato.value = {}
  adeudos.value = []
  infoConvenio.value = null
  infoLicencia.value = null
  datosCancel.value = {
    anio: ejercicioActual,
    mes: '12',
    fechaBaja: fechaHoy,
    documento: '',
    descripcion: ''
  }
}

// Salir
const salir = () => {
  router.push('/aseo-contratado')
}

// Inicializar
onMounted(async () => {
  showLoading()
  try {
    await cargarTiposAseo()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al inicializar')
  } finally {
    hideLoading()
  }
})
</script>
