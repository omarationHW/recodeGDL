<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-pen" />
      </div>
      <div class="module-view-info">
        <h1>Modificación de Contratos</h1>
        <p>Aseo Contratado - Edición de contratos existentes</p>
      </div>
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Contrato</label>
              <div class="input-group">
                <input type="number" v-model="numContratoBuscar" class="municipal-form-control"
                  placeholder="Ingrese número de contrato" @keyup.enter="buscarContrato" />
                <button class="btn-municipal-secondary" @click="buscarContrato" :disabled="loading" type="button">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Edición -->
      <form v-if="contratoEncontrado" @submit.prevent="actualizarContrato" class="mt-3">
        <!-- Información de la Empresa -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="building" /> Información de la Empresa</h5>
          </div>
          <div class="municipal-card-body">
            <div class="alert alert-info">
              <font-awesome-icon icon="info-circle" />
              La empresa asociada al contrato no se puede modificar desde este formulario
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Empresa</label>
                <input type="text" :value="formData.nombre_empresa" class="municipal-form-control" readonly />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Representante</label>
                <input type="text" :value="formData.representante_empresa" class="municipal-form-control" readonly />
              </div>
            </div>
          </div>
        </div>

        <!-- Información del Domicilio -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="map-marker-alt" /> Domicilio del Servicio</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Calle</label>
                <input type="text" v-model="formData.calle" class="municipal-form-control" required maxlength="100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Número Exterior</label>
                <input type="text" v-model="formData.numext" class="municipal-form-control" required maxlength="10" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Número Interior</label>
                <input type="text" v-model="formData.numint" class="municipal-form-control" maxlength="10" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Colonia</label>
                <input type="text" v-model="formData.colonia" class="municipal-form-control" required maxlength="100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sector</label>
                <input type="text" v-model="formData.sector" class="municipal-form-control" maxlength="50" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Código Postal</label>
                <input type="text" v-model="formData.cp" class="municipal-form-control" maxlength="5" pattern="[0-9]{5}" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Municipio</label>
                <input type="text" v-model="formData.municipio" class="municipal-form-control" required maxlength="100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Estado</label>
                <input type="text" v-model="formData.estado" class="municipal-form-control" required maxlength="50" />
              </div>
            </div>
          </div>
        </div>

        <!-- Información del Contrato -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-header">
            <h5><font-awesome-icon icon="file-contract" /> Datos del Contrato</h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Número de Contrato</label>
                <input type="number" :value="formData.num_contrato" class="municipal-form-control" readonly />
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Tipo de Aseo</label>
                <select v-model="formData.tipo_aseo" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="tipo in tiposAseo" :key="tipo.tipo_aseo" :value="tipo.tipo_aseo">
                    {{ tipo.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Status</label>
                <select v-model="formData.status_contrato" class="municipal-form-control">
                  <option value="N">Nuevo</option>
                  <option value="V">Vigente</option>
                  <option value="B">Baja</option>
                  <option value="C">Cancelado</option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Unidad de Recolección</label>
                <select v-model="formData.cve_recoleccion" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="unidad in unidadesRecoleccion" :key="unidad.cve_recolec" :value="unidad.cve_recolec">
                    {{ unidad.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label required">Cantidad de Unidades</label>
                <input type="number" v-model="formData.cantidad_recoleccion" class="municipal-form-control"
                  required min="1" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label required">Inicio de Obligación</label>
                <input type="month" v-model="formData.inicio_oblig" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fin de Obligación</label>
                <input type="month" v-model="formData.fin_oblig" class="municipal-form-control" />
                <small class="form-text">Dejar vacío si es indefinido</small>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">RFC</label>
                <input type="text" v-model="formData.rfc" class="municipal-form-control" maxlength="13" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">CURP</label>
                <input type="text" v-model="formData.curp" class="municipal-form-control" maxlength="18" />
              </div>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="municipal-card mt-3">
          <div class="municipal-card-body">
            <div class="button-group">
              <button type="submit" class="btn-municipal-primary" :disabled="loading || !isFormValid">
                <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
                {{ loading ? 'Guardando...' : 'Guardar Cambios' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="cancelarEdicion" :disabled="loading">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </div>
        </div>
      </form>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !contratoEncontrado" class="municipal-card mt-3">
        <div class="municipal-card-body text-center py-5">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <p class="text-muted">No se encontró el contrato especificado</p>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Modificación de Contratos">
      <h3>Modificación de Contratos</h3>
      <p>Este módulo permite actualizar la información de contratos existentes.</p>

      <h4>Procedimiento:</h4>
      <ol>
        <li>Busque el contrato por su número</li>
        <li>Revise la información actual</li>
        <li>Modifique los campos necesarios</li>
        <li>Guarde los cambios</li>
      </ol>

      <h4>Campos Editables:</h4>
      <ul>
        <li>Domicilio completo del servicio</li>
        <li>Tipo de aseo</li>
        <li>Unidades de recolección y cantidad</li>
        <li>Periodo de vigencia</li>
        <li>RFC y CURP</li>
        <li>Status del contrato</li>
      </ul>

      <h4>Campos NO Editables:</h4>
      <ul>
        <li>Número de contrato</li>
        <li>Empresa asociada</li>
        <li>Representante</li>
      </ul>

      <h4>Status de Contratos:</h4>
      <ul>
        <li><strong>Nuevo (N):</strong> Contrato recién registrado</li>
        <li><strong>Vigente (V):</strong> Contrato activo</li>
        <li><strong>Baja (B):</strong> Contrato dado de baja</li>
        <li><strong>Cancelado (C):</strong> Contrato cancelado</li>
      </ul>

      <h4>Notas Importantes:</h4>
      <ul>
        <li>Verifique que los cambios no afecten adeudos existentes</li>
        <li>El cambio de status debe ser autorizado</li>
        <li>Los cambios quedan registrados en el historial</li>
      </ul>
    </DocumentationModal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const numContratoBuscar = ref(null)
const contratoEncontrado = ref(false)
const busquedaRealizada = ref(false)
const tiposAseo = ref([])
const unidadesRecoleccion = ref([])

const formData = ref({
  control_contrato: null,
  num_contrato: null,
  num_empresa: null,
  nombre_empresa: '',
  representante_empresa: '',
  tipo_aseo: '',
  cve_recoleccion: '',
  cantidad_recoleccion: 1,
  calle: '',
  numext: '',
  numint: '',
  colonia: '',
  sector: '',
  cp: '',
  municipio: '',
  estado: '',
  rfc: '',
  curp: '',
  inicio_oblig: '',
  fin_oblig: '',
  status_contrato: 'N'
})

const isFormValid = computed(() => {
  return formData.value.calle &&
         formData.value.numext &&
         formData.value.colonia &&
         formData.value.municipio &&
         formData.value.estado &&
         formData.value.tipo_aseo &&
         formData.value.cve_recoleccion &&
         formData.value.cantidad_recoleccion > 0 &&
         formData.value.inicio_oblig
})

const buscarContrato = async () => {
  if (!numContratoBuscar.value) {
    showToast('Ingrese un número de contrato', 'warning')
    return
  }

  loading.value = true
  busquedaRealizada.value = true
  contratoEncontrado.value = false

  try {
    const response = await execute('sp16_contratos_buscar', 'aseo_contratado', {
      parContrato: numContratoBuscar.value,
      parTipo: 'T',
      parVigencia: 'T'
    })

    if (response && response.data && response.data.length > 0) {
      const contrato = response.data[0]
      contratoEncontrado.value = true

      // Convertir fechas de YYYY-MM a formato month input
      formData.value = {
        control_contrato: contrato.control_contrato,
        num_contrato: contrato.num_contrato,
        num_empresa: contrato.num_empresa,
        nombre_empresa: contrato.nombre_empresa,
        representante_empresa: contrato.representante_empresa,
        tipo_aseo: contrato.tipo_aseo,
        cve_recoleccion: contrato.cve_recoleccion,
        cantidad_recoleccion: contrato.cantidad_recoleccion,
        calle: contrato.calle || '',
        numext: contrato.numext || '',
        numint: contrato.numint || '',
        colonia: contrato.colonia || '',
        sector: contrato.sector || '',
        cp: contrato.cp || '',
        municipio: contrato.municipio || '',
        estado: contrato.estado || '',
        rfc: contrato.rfc || '',
        curp: contrato.curp || '',
        inicio_oblig: contrato.inicio_oblig || '',
        fin_oblig: contrato.fin_oblig || '',
        status_contrato: contrato.status_contrato || 'N'
      }
    } else {
      showToast('Contrato no encontrado', 'warning')
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al buscar el contrato', 'error')
  } finally {
    loading.value = false
  }
}

const actualizarContrato = async () => {
  if (!isFormValid.value) {
    showToast('Complete todos los campos requeridos', 'warning')
    return
  }

  const result = await Swal.fire({
    title: '¿Actualizar Contrato?',
    html: `<p>Contrato: <strong>${formData.value.num_contrato}</strong></p>
           <p>Empresa: <strong>${formData.value.nombre_empresa}</strong></p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  loading.value = true

  try {
    // Convertir fechas a formato DATE
    const fechaInicio = formData.value.inicio_oblig ? `${formData.value.inicio_oblig}-01` : null
    const fechaFin = formData.value.fin_oblig ? `${formData.value.fin_oblig}-01` : null

    // Nota: Este SP debe ser creado
    const response = await execute('SP_ASEO_CONTRATOS_UPDATE', 'aseo_contratado', {
      p_control_contrato: formData.value.control_contrato,
      p_tipo_aseo: formData.value.tipo_aseo,
      p_cve_recoleccion: formData.value.cve_recoleccion,
      p_cantidad_recoleccion: formData.value.cantidad_recoleccion,
      p_calle: formData.value.calle,
      p_numext: formData.value.numext,
      p_numint: formData.value.numint || null,
      p_colonia: formData.value.colonia,
      p_sector: formData.value.sector || null,
      p_cp: formData.value.cp || null,
      p_municipio: formData.value.municipio,
      p_estado: formData.value.estado,
      p_rfc: formData.value.rfc || null,
      p_curp: formData.value.curp || null,
      p_inicio_oblig: fechaInicio,
      p_fin_oblig: fechaFin,
      p_status_contrato: formData.value.status_contrato
    })

    if (response && response.data && response.data[0]) {
      const result = response.data[0]

      if (result.success) {
        showToast('Contrato actualizado exitosamente', 'success')
        cancelarEdicion()
      } else {
        showToast(result.message || 'Error al actualizar el contrato', 'error')
      }
    }
  } catch (error) {
    console.error('Error:', error)
    showToast('Error al actualizar el contrato', 'error')
  } finally {
    loading.value = false
  }
}

const cancelarEdicion = () => {
  contratoEncontrado.value = false
  busquedaRealizada.value = false
  numContratoBuscar.value = null
  formData.value = {
    control_contrato: null,
    num_contrato: null,
    num_empresa: null,
    nombre_empresa: '',
    representante_empresa: '',
    tipo_aseo: '',
    cve_recoleccion: '',
    cantidad_recoleccion: 1,
    calle: '',
    numext: '',
    numint: '',
    colonia: '',
    sector: '',
    cp: '',
    municipio: '',
    estado: '',
    rfc: '',
    curp: '',
    inicio_oblig: '',
    fin_oblig: '',
    status_contrato: 'N'
  }
}

const cargarTiposAseo = async () => {
  try {
    const response = await execute('SP_ASEO_TIPOS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      tiposAseo.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar tipos de aseo:', error)
  }
}

const cargarUnidadesRecoleccion = async () => {
  try {
    const response = await execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })

    if (response && response.data) {
      unidadesRecoleccion.value = response.data
    }
  } catch (error) {
    console.error('Error al cargar unidades de recolección:', error)
  }
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(() => {
  cargarTiposAseo()
  cargarUnidadesRecoleccion()
})
</script>
