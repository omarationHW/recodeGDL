<template>
  <div class="module-view">
    <!-- HEADER -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Gesti�n de Recaudadoras</h1>
        <p>Mercados - Administraci�n de oficinas recaudadoras</p>
      </div>
      <button class="btn-help-icon" @click="mostrarAyuda" type="button">
        <font-awesome-icon icon="question-circle" /> Ayuda
      </button>
    </div>

    <!-- ACCIONES -->
    <div class="municipal-card">
      <div >
        <div class="form-row">
          <button
            type="button"
            class="btn-municipal-success"
            @click="nuevaRecaudadora"
            :disabled="cargando"
          >
            <font-awesome-icon icon="plus" /> Nueva Recaudadora
          </button>

          <button
            type="button"
            class="btn-municipal-info"
            @click="exportarExcel"
            :disabled="cargando || recaudadoras.length === 0"
          >
            <font-awesome-icon icon="file-excel" /> Exportar Excel
          </button>

          <button
            type="button"
            class="btn-municipal-primary"
            @click="cargarDatos"
            :disabled="cargando"
          >
            <font-awesome-icon icon="sync-alt" /> Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- ESTAD�STICAS -->
    <div v-if="recaudadoras.length > 0" class="municipal-card">
      <div class="stats-dashboard">
        <div class="stat-item stat-primary">
          <div class="stat-value">{{ recaudadoras.length }}</div>
          <div class="stat-label">Total Recaudadoras</div>
          <div class="stat-sublabel">Registradas</div>
        </div>

        <div class="stat-item stat-success">
          <div class="stat-value">{{ recaudadorasVigentes }}</div>
          <div class="stat-label">Recaudadoras Vigentes</div>
          <div class="stat-sublabel">Activas</div>
        </div>

        <div class="stat-item stat-info">
          <div class="stat-value">{{ totalMercados }}</div>
          <div class="stat-label">Total Mercados</div>
          <div class="stat-sublabel">En todas las recaudadoras</div>
        </div>

        <div class="stat-item stat-warning">
          <div class="stat-value">{{ totalLocales }}</div>
          <div class="stat-label">Total Locales</div>
          <div class="stat-sublabel">En todas las recaudadoras</div>
        </div>
      </div>
    </div>

    <!-- TABLA DE RECAUDADORAS -->
    <div v-if="recaudadoras.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5><font-awesome-icon icon="table" /> Listado de Recaudadoras</h5>
      </div>

      <div class="municipal-table">
        <table class="municipal-table">
          <thead>
            <tr>
              <th class="text-center">#</th>
              <th class="text-center">Oficina</th>
              <th>Recaudadora</th>
              <th>Domicilio</th>
              <th>Tel�fono</th>
              <th>Responsable</th>
              <th class="text-center">Mercados</th>
              <th class="text-center">Locales</th>
              <th class="text-center">Vigencia</th>
              <th class="text-center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in recaudadoras" :key="item.oficina">
              <td class="text-center">{{ index + 1 }}</td>
              <td class="text-center">
                <span class="badge-primary">{{ item.oficina }}</span>
              </td>
              <td>{{ item.recaudadora }}</td>
              <td>{{ item.domicilio || '-' }}</td>
              <td>{{ item.telefono || '-' }}</td>
              <td>{{ item.responsable || '-' }}</td>
              <td class="text-center">{{ item.total_mercados }}</td>
              <td class="text-center">{{ item.total_locales }}</td>
              <td class="text-center">
                <span class="badge item.vigencia === 'V' ? 'badge-success' : 'badge-danger'" :>
                  {{ item.vigencia === 'V' ? 'Vigente' : 'Baja' }}
                </span>
              </td>
              <td class="text-center">
                <button
                  type="button"
                  class="btn-icon btn-warning"
                  @click="editarRecaudadora(item)"
                  title="Editar"
                >
                  <font-awesome-icon icon="edit" />
                </button>
                <button
                  type="button"
                  class="btn-icon btn-danger"
                  @click="eliminarRecaudadora(item)"
                  title="Eliminar"
                >
                  <font-awesome-icon icon="trash" />
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- SIN DATOS -->
    <div v-else-if="!cargando" class="municipal-card">
      <div class="alert alert-info">
        <font-awesome-icon icon="info-circle" />
        No hay recaudadoras registradas en el sistema.
      </div>
    </div>

    <!-- MODAL FORMULARIO -->
    <div v-if="mostrarFormulario" class="modal-overlay" @click.self="cerrarFormulario">
      <div class="modal-content">
        <div class="modal-header">
          <h2>
            <font-awesome-icon :icon="modoEdicion ? 'edit' : 'plus'" />
            {{ modoEdicion ? 'Editar' : 'Nueva' }} Recaudadora
          </h2>
          <button type="button" class="btn-close" @click="cerrarFormulario">&times;</button>
        </div>

        <form @submit.prevent="guardarRecaudadora" >
          <div class="modal-body">
            <div class="form-row">
              <div class="form-group">
                <label for="oficina" class="municipal-form-label required">N�mero de Oficina:</label>
                <input
                  type="number"
                  v-model.number="formulario.oficina"
                  id="oficina"
                  class="municipal-form-control"
                  required
                  :disabled="guardando || modoEdicion"
                  min="1"
                  placeholder="Ej: 1"
                />
                <small v-if="modoEdicion" class="form-text text-muted">
                  El n�mero de oficina no se puede modificar
                </small>
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="recaudadora" class="municipal-form-label required">Nombre de Recaudadora:</label>
                <input
                  type="text"
                  v-model="formulario.recaudadora"
                  id="recaudadora"
                  class="municipal-form-control"
                  required
                  :disabled="guardando"
                  maxlength="100"
                  placeholder="Nombre de la recaudadora"
                />
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="domicilio" class="municipal-form-label">Domicilio:</label>
                <input
                  type="text"
                  v-model="formulario.domicilio"
                  id="domicilio"
                  class="municipal-form-control"
                  :disabled="guardando"
                  maxlength="100"
                  placeholder="Direcci�n de la oficina"
                />
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="telefono" class="municipal-form-label">Tel�fono:</label>
                <input
                  type="text"
                  v-model="formulario.telefono"
                  id="telefono"
                  class="municipal-form-control"
                  :disabled="guardando"
                  maxlength="20"
                  placeholder="N�mero de tel�fono"
                />
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="responsable" class="municipal-form-label">Responsable:</label>
                <input
                  type="text"
                  v-model="formulario.responsable"
                  id="responsable"
                  class="municipal-form-control"
                  :disabled="guardando"
                  maxlength="100"
                  placeholder="Nombre del responsable"
                />
              </div>
        </div>

            <div class="form-row">
              <div class="form-group">
                <label for="vigencia" class="municipal-form-label required">Vigencia:</label>
                <select
                  v-model="formulario.vigencia"
                  id="vigencia"
                  class="municipal-form-control"
                  required
                  :disabled="guardando"
                >
                  <option value="">Seleccione...</option>
                  <option value="V">Vigente</option>
                  <option value="B">Baja</option>
                </select>
              </div>
        </div>
          </div>

          <div class="modal-footer">
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="cerrarFormulario"
              :disabled="guardando"
            >
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button
              type="submit"
              class="btn-municipal-success"
              :disabled="guardando"
            >
              <font-awesome-icon icon="save" /> Guardar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'
import * as XLSX from 'xlsx'

const { execute } = useApi()
const { handleError } = useLicenciasErrorHandler()
const { showToast } = useToast()

// Estado
const cargando = ref(false)
const guardando = ref(false)
const mostrarFormulario = ref(false)
const modoEdicion = ref(false)
const recaudadoras = ref([])

// Formulario
const formulario = ref({
  oficina: '',
  recaudadora: '',
  domicilio: '',
  telefono: '',
  responsable: '',
  vigencia: 'V'
})

// Computed
const recaudadorasVigentes = computed(() => {
  return recaudadoras.value.filter(r => r.vigencia === 'V').length
})

const totalMercados = computed(() => {
  return recaudadoras.value.reduce((sum, r) => sum + (r.total_mercados || 0), 0)
})

const totalLocales = computed(() => {
  return recaudadoras.value.reduce((sum, r) => sum + (r.total_locales || 0), 0)
})

// Cargar datos al montar
onMounted(() => {
  cargarDatos()
})

// Cargar recaudadoras
async function cargarDatos() {
  try {
    cargando.value = true
    const response = await execute('SP_MERCADOS_RECAUDADORAS_ADMIN_LIST', 'mercados', {})
    recaudadoras.value = response || []
  } catch (error) {
    handleError(error)
  } finally {
    cargando.value = false
  }
}

// Nueva recaudadora
function nuevaRecaudadora() {
  modoEdicion.value = false
  formulario.value = {
    oficina: '',
    recaudadora: '',
    domicilio: '',
    telefono: '',
    responsable: '',
    vigencia: 'V'
  }
  mostrarFormulario.value = true
}

// Editar recaudadora
function editarRecaudadora(recaudadora) {
  modoEdicion.value = true
  formulario.value = {
    oficina: recaudadora.oficina,
    recaudadora: recaudadora.recaudadora,
    domicilio: recaudadora.domicilio,
    telefono: recaudadora.telefono,
    responsable: recaudadora.responsable,
    vigencia: recaudadora.vigencia
  }
  mostrarFormulario.value = true
}

// Guardar recaudadora
async function guardarRecaudadora() {
  try {
    guardando.value = true

    if (modoEdicion.value) {
      await execute('SP_MERCADOS_RECAUDADORAS_ADMIN_UPDATE', 'mercados', {
        p_oficina: formulario.value.oficina,
        p_recaudadora: formulario.value.recaudadora,
        p_domicilio: formulario.value.domicilio || null,
        p_telefono: formulario.value.telefono || null,
        p_responsable: formulario.value.responsable || null,
        p_vigencia: formulario.value.vigencia
      })
      showToast('Recaudadora actualizada correctamente', 'success')
    } else {
      await execute('SP_MERCADOS_RECAUDADORAS_ADMIN_CREATE', 'mercados', {
        p_oficina: formulario.value.oficina,
        p_recaudadora: formulario.value.recaudadora,
        p_domicilio: formulario.value.domicilio || null,
        p_telefono: formulario.value.telefono || null,
        p_responsable: formulario.value.responsable || null,
        p_vigencia: formulario.value.vigencia
      })
      showToast('Recaudadora creada correctamente', 'success')
    }

    cerrarFormulario()
    await cargarDatos()

  } catch (error) {
    handleError(error)
  } finally {
    guardando.value = false
  }
}

// Eliminar recaudadora
async function eliminarRecaudadora(recaudadora) {
  const result = await Swal.fire({
    title: '�Eliminar recaudadora?',
    html: `�Est� seguro de eliminar la recaudadora:<br>
           <strong>Oficina ${recaudadora.oficina} - ${recaudadora.recaudadora}</strong>?<br><br>
           <small class="text-danger">Esta acci�n no se puede deshacer y fallar� si tiene mercados asociados.</small>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'S�, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#d33'
  })

  if (result.isConfirmed) {
    try {
      await execute('SP_MERCADOS_RECAUDADORAS_ADMIN_DELETE', 'mercados', {
        p_oficina: recaudadora.oficina
      })
      showToast('Recaudadora eliminada correctamente', 'success')
      await cargarDatos()
    } catch (error) {
      handleError(error)
    }
  }
}

// Cerrar formulario
function cerrarFormulario() {
  mostrarFormulario.value = false
  modoEdicion.value = false
}

// Exportar a Excel
function exportarExcel() {
  try {
    const datos = recaudadoras.value.map((item, idx) => ({
      '#': idx + 1,
      'Oficina': item.oficina,
      'Recaudadora': item.recaudadora,
      'Domicilio': item.domicilio,
      'Tel�fono': item.telefono,
      'Responsable': item.responsable,
      'Total Mercados': item.total_mercados,
      'Total Locales': item.total_locales,
      'Vigencia': item.vigencia === 'V' ? 'Vigente' : 'Baja'
    }))

    const ws = XLSX.utils.json_to_sheet(datos)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Recaudadoras')

    const nombreArchivo = `Recaudadoras_Mercados_${new Date().toISOString().split('T')[0]}.xlsx`

    XLSX.writeFile(wb, nombreArchivo)
    showToast('Archivo Excel generado correctamente', 'success')
  } catch (error) {
    handleError(error)
  }
}

// Mostrar ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Gesti�n de Recaudadoras',
    html: `
      <div class="help-content" style="text-align: left;">
        <h3>Descripci�n</h3>
        <p>Este m�dulo permite administrar el cat�logo de recaudadoras u oficinas responsables de la administraci�n de mercados y locales.</p>

        <h3>�Qu� son las Recaudadoras?</h3>
        <p>Las recaudadoras son oficinas municipales responsables de:</p>
        <ul>
          <li>Administrar uno o varios mercados</li>
          <li>Gestionar el cobro de cuotas y servicios</li>
          <li>Supervisar la operaci�n de locales</li>
          <li>Realizar tr�mites administrativos</li>
        </ul>

        <h3>Gesti�n de Recaudadoras</h3>
        <ul>
          <li><strong>Nueva Recaudadora:</strong> Permite registrar una nueva oficina recaudadora</li>
          <li><strong>Editar:</strong> Modifica los datos de la recaudadora</li>
          <li><strong>Eliminar:</strong> Elimina una recaudadora (solo si no tiene mercados asociados)</li>
          <li><strong>Actualizar:</strong> Recarga el listado desde la base de datos</li>
          <li><strong>Exportar Excel:</strong> Descarga el cat�logo completo en formato Excel</li>
        </ul>

        <h3>Campos de la Recaudadora</h3>
        <ul>
          <li><strong>N�mero de Oficina:</strong> Identificador �nico (no modificable una vez creado)</li>
          <li><strong>Nombre de Recaudadora:</strong> Denominaci�n oficial de la oficina</li>
          <li><strong>Domicilio:</strong> Direcci�n f�sica de la oficina (opcional)</li>
          <li><strong>Tel�fono:</strong> N�mero de contacto (opcional)</li>
          <li><strong>Responsable:</strong> Nombre del titular o responsable (opcional)</li>
          <li><strong>Vigencia:</strong> Estado de la recaudadora (Vigente/Baja)</li>
        </ul>

        <h3>Estad�sticas Mostradas</h3>
        <ul>
          <li><strong>Total Mercados:</strong> Suma de mercados administrados por cada recaudadora</li>
          <li><strong>Total Locales:</strong> Suma de locales registrados en todas las recaudadoras</li>
          <li>Estas cifras se actualizan autom�ticamente al cargar los datos</li>
        </ul>

        <h3>Validaciones</h3>
        <ul>
          <li>No se pueden crear dos recaudadoras con el mismo n�mero de oficina</li>
          <li>Al editar, el n�mero de oficina no se puede modificar</li>
          <li>No se puede eliminar una recaudadora que tenga mercados asociados</li>
          <li>El nombre de la recaudadora es obligatorio</li>
        </ul>

        <h3>Uso en el Sistema</h3>
        <ul>
          <li>Las recaudadoras son utilizadas para organizar geogr�ficamente los mercados</li>
          <li>Permiten generar reportes por oficina responsable</li>
          <li>Facilitan el control y seguimiento administrativo</li>
          <li>Son necesarias para asignar mercados y locales</li>
        </ul>

        <h3>Notas Importantes</h3>
        <ul>
          <li>Dar de baja una recaudadora no elimina sus mercados ni locales asociados</li>
          <li>Se recomienda no eliminar recaudadoras, sino marcarlas como "Baja"</li>
          <li>Los n�meros de oficina deben ser �nicos y consecutivos</li>
        </ul>
      </div>
    `,
    icon: 'info',
    width: 800,
    confirmButtonText: 'Entendido'
  })
}
</script>


