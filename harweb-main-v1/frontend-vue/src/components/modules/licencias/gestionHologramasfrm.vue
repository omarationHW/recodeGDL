<template>
  <div class="container-fluid px-4 py-3">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb bg-light rounded p-3">
        <li class="breadcrumb-item"><i class="fas fa-home"></i> <router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><i class="fas fa-shield-alt"></i> Seguridad</li>
        <li class="breadcrumb-item active" aria-current="page">Gestión de Hologramas</li>
      </ol>
    </nav>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h3 mb-1"><i class="fas fa-qrcode text-primary me-2"></i>Gestión de Hologramas</h2>
            <p class="text-muted mb-0">Control de inventario y verificación de hologramas con códigos QR</p>
          </div>
          <div>
            <button class="btn btn-info me-2" @click="showStatsModal = true" title="Ver Estadísticas">
              <i class="fas fa-chart-bar me-1"></i>Estadísticas
            </button>
            <button class="btn btn-success me-2" @click="generateQRCodes" title="Generar Códigos QR">
              <i class="fas fa-qrcode me-1"></i>Generar QR
            </button>
            <button class="btn btn-primary" @click="showModal = true; modalTitle = 'Nuevo Holograma'; currentItem = {};">
              <i class="fas fa-plus me-1"></i>Nuevo Holograma
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label">Buscar por código:</label>
            <input v-model="filters.codigo" @input="loadHologramas" type="text" class="form-control" placeholder="Código de holograma...">
          </div>
          <div class="col-md-2">
            <label class="form-label">Estado:</label>
            <select v-model="filters.estado" @change="loadHologramas" class="form-select">
              <option value="">Todos</option>
              <option value="disponible">Disponible</option>
              <option value="asignado">Asignado</option>
              <option value="usado">Usado</option>
              <option value="cancelado">Cancelado</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Tipo:</label>
            <select v-model="filters.tipo" @change="loadHologramas" class="form-select">
              <option value="">Todos</option>
              <option value="licencia">Licencia</option>
              <option value="anuncio">Anuncio</option>
              <option value="especial">Especial</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Año:</label>
            <select v-model="filters.anio" @change="loadHologramas" class="form-select">
              <option value="">Todos</option>
              <option v-for="year in availableYears" :key="year" :value="year">{{ year }}</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Con QR:</label>
            <select v-model="filters.tieneQR" @change="loadHologramas" class="form-select">
              <option value="">Todos</option>
              <option value="1">Con QR</option>
              <option value="0">Sin QR</option>
            </select>
          </div>
          <div class="col-md-1 d-flex align-items-end">
            <button @click="resetFilters" class="btn btn-outline-secondary">
              <i class="fas fa-eraser me-1"></i>Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de hologramas -->
    <div class="card">
      <div class="card-header bg-light">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Inventario de Hologramas</h5>
          <div class="d-flex align-items-center">
            <span class="badge bg-success me-2">Disponibles: {{ stats.disponibles || 0 }}</span>
            <span class="badge bg-warning me-2">Asignados: {{ stats.asignados || 0 }}</span>
            <span class="badge bg-danger">Usados: {{ stats.usados || 0 }}</span>
          </div>
        </div>
      </div>
      <div class="card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status"></div>
          <p class="mt-2 mb-0">Cargando hologramas...</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-hover mb-0">
              <thead class="table-light">
                <tr>
                  <th>ID</th>
                  <th>Código</th>
                  <th>Tipo</th>
                  <th>Estado</th>
                  <th>Año</th>
                  <th>QR Code</th>
                  <th>Fecha Creación</th>
                  <th>Asignado A</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="holograma in hologramas" :key="holograma.id">
                  <td>{{ holograma.id }}</td>
                  <td>
                    <div class="d-flex align-items-center">
                      <i class="fas fa-barcode text-muted me-2"></i>
                      <span class="font-monospace">{{ holograma.codigo }}</span>
                    </div>
                  </td>
                  <td>
                    <span :class="getTipoClass(holograma.tipo)">{{ holograma.tipo }}</span>
                  </td>
                  <td>
                    <span :class="getEstadoClass(holograma.estado)">{{ holograma.estado }}</span>
                  </td>
                  <td>{{ holograma.anio }}</td>
                  <td>
                    <div v-if="holograma.qr_code" class="d-flex align-items-center">
                      <img :src="holograma.qr_code" alt="QR Code" width="32" height="32" class="me-2">
                      <i class="fas fa-check-circle text-success"></i>
                    </div>
                    <span v-else class="text-muted">
                      <i class="fas fa-times-circle text-danger me-1"></i>Sin QR
                    </span>
                  </td>
                  <td>{{ formatDate(holograma.fecha_creacion) }}</td>
                  <td>
                    <span v-if="holograma.asignado_a" class="badge bg-info">{{ holograma.asignado_a }}</span>
                    <span v-else class="text-muted">No asignado</span>
                  </td>
                  <td>
                    <button @click="editItem(holograma)" class="btn btn-sm btn-outline-primary me-1" title="Editar">
                      <i class="fas fa-edit"></i>
                    </button>
                    <button @click="viewQR(holograma)" class="btn btn-sm btn-outline-info me-1" title="Ver QR" :disabled="!holograma.qr_code">
                      <i class="fas fa-qrcode"></i>
                    </button>
                    <button @click="asignarHolograma(holograma)" class="btn btn-sm btn-outline-warning me-1" title="Asignar a Licencia" :disabled="holograma.estado !== 'disponible'">
                      <i class="fas fa-link"></i>
                    </button>
                    <button @click="verifyHolograma(holograma)" class="btn btn-sm btn-outline-success me-1" title="Verificar">
                      <i class="fas fa-check-circle"></i>
                    </button>
                    <button @click="deleteItem(holograma)" class="btn btn-sm btn-outline-danger" title="Eliminar">
                      <i class="fas fa-trash"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="pagination.total > pagination.limit" class="d-flex justify-content-between align-items-center p-3 bg-light">
            <span class="text-muted">
              Mostrando {{ ((pagination.page - 1) * pagination.limit) + 1 }} a {{ Math.min(pagination.page * pagination.limit, pagination.total) }} de {{ pagination.total }} registros
            </span>
            <nav>
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: pagination.page <= 1 }">
                  <button class="page-link" @click="changePage(pagination.page - 1)">Anterior</button>
                </li>
                <li v-for="page in getPageNumbers()" :key="page" class="page-item" :class="{ active: page === pagination.page }">
                  <button class="page-link" @click="changePage(page)">{{ page }}</button>
                </li>
                <li class="page-item" :class="{ disabled: pagination.page >= Math.ceil(pagination.total / pagination.limit) }">
                  <button class="page-link" @click="changePage(pagination.page + 1)">Siguiente</button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para holograma -->
    <div class="modal fade" :class="{ show: showModal }" :style="{ display: showModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ modalTitle }}</h5>
            <button type="button" class="btn-close" @click="closeModal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="saveItem">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Código <span class="text-danger">*</span></label>
                  <input v-model="currentItem.codigo" type="text" class="form-control font-monospace" required>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Tipo <span class="text-danger">*</span></label>
                  <select v-model="currentItem.tipo" class="form-select" required>
                    <option value="licencia">Licencia</option>
                    <option value="anuncio">Anuncio</option>
                    <option value="especial">Especial</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Estado <span class="text-danger">*</span></label>
                  <select v-model="currentItem.estado" class="form-select" required>
                    <option value="disponible">Disponible</option>
                    <option value="asignado">Asignado</option>
                    <option value="usado">Usado</option>
                    <option value="cancelado">Cancelado</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Año <span class="text-danger">*</span></label>
                  <input v-model="currentItem.anio" type="number" class="form-control" :min="2020" :max="2030" required>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Asignado a</label>
                  <input v-model="currentItem.asignado_a" type="text" class="form-control">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Generar QR</label>
                  <div class="form-check form-switch">
                    <input v-model="currentItem.generar_qr" class="form-check-input" type="checkbox" id="generarQR">
                    <label class="form-check-label" for="generarQR">
                      Generar código QR automáticamente
                    </label>
                  </div>
                </div>
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea v-model="currentItem.observaciones" class="form-control" rows="2"></textarea>
                </div>
                <div v-if="currentItem.qr_code" class="col-12 text-center">
                  <label class="form-label">Código QR Actual</label>
                  <div>
                    <img :src="currentItem.qr_code" alt="QR Code" class="img-thumbnail" style="max-width: 200px;">
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
            <button type="button" class="btn btn-primary" @click="saveItem">
              <i class="fas fa-save me-1"></i>Guardar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de QR Code -->
    <div class="modal fade" :class="{ show: showQRModal }" :style="{ display: showQRModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Código QR - {{ selectedHolograma?.codigo }}</h5>
            <button type="button" class="btn-close" @click="showQRModal = false"></button>
          </div>
          <div class="modal-body text-center">
            <div v-if="selectedHolograma?.qr_code">
              <img :src="selectedHolograma.qr_code" alt="QR Code" class="img-fluid mb-3" style="max-width: 300px;">
              <div class="mt-3">
                <button @click="downloadQR" class="btn btn-primary me-2">
                  <i class="fas fa-download me-1"></i>Descargar
                </button>
                <button @click="printQR" class="btn btn-outline-secondary">
                  <i class="fas fa-print me-1"></i>Imprimir
                </button>
              </div>
            </div>
            <div v-else class="text-muted">
              <i class="fas fa-exclamation-triangle fa-3x mb-3"></i>
              <p>No hay código QR disponible para este holograma.</p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de estadísticas -->
    <div class="modal fade" :class="{ show: showStatsModal }" :style="{ display: showStatsModal ? 'block' : 'none' }" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Estadísticas de Hologramas</h5>
            <button type="button" class="btn-close" @click="showStatsModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="row g-4">
              <div class="col-md-6">
                <div class="card bg-success text-white">
                  <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                      <div>
                        <h4 class="mb-0">{{ detailStats.disponibles || 0 }}</h4>
                        <p class="mb-0">Disponibles</p>
                      </div>
                      <i class="fas fa-check-circle fa-2x opacity-75"></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card bg-warning text-white">
                  <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                      <div>
                        <h4 class="mb-0">{{ detailStats.asignados || 0 }}</h4>
                        <p class="mb-0">Asignados</p>
                      </div>
                      <i class="fas fa-user-tag fa-2x opacity-75"></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card bg-danger text-white">
                  <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                      <div>
                        <h4 class="mb-0">{{ detailStats.usados || 0 }}</h4>
                        <p class="mb-0">Usados</p>
                      </div>
                      <i class="fas fa-times-circle fa-2x opacity-75"></i>
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card bg-info text-white">
                  <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                      <div>
                        <h4 class="mb-0">{{ detailStats.total || 0 }}</h4>
                        <p class="mb-0">Total</p>
                      </div>
                      <i class="fas fa-qrcode fa-2x opacity-75"></i>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Estadísticas por tipo -->
            <div class="mt-4">
              <h6>Distribución por Tipo</h6>
              <div class="table-responsive">
                <table class="table table-sm">
                  <thead>
                    <tr>
                      <th>Tipo</th>
                      <th>Disponibles</th>
                      <th>Asignados</th>
                      <th>Usados</th>
                      <th>Total</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="stat in detailStats.porTipo" :key="stat.tipo">
                      <td><span :class="getTipoClass(stat.tipo)">{{ stat.tipo }}</span></td>
                      <td>{{ stat.disponibles }}</td>
                      <td>{{ stat.asignados }}</td>
                      <td>{{ stat.usados }}</td>
                      <td><strong>{{ stat.total }}</strong></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showModal || showQRModal || showStatsModal" class="modal-backdrop fade show"></div>
  </div>
</template>

<script>
import Swal from 'sweetalert2'

export default {
  name: 'GestionHologramasPage',
  data() {
    return {
      hologramas: [],
      loading: false,
      showModal: false,
      showQRModal: false,
      showStatsModal: false,
      modalTitle: '',
      selectedHolograma: null,
      currentItem: {
        codigo: '',
        tipo: 'licencia',
        estado: 'disponible',
        anio: new Date().getFullYear(),
        asignado_a: '',
        observaciones: '',
        generar_qr: true
      },
      filters: {
        codigo: '',
        estado: '',
        tipo: '',
        anio: '',
        tieneQR: ''
      },
      stats: {
        disponibles: 0,
        asignados: 0,
        usados: 0,
        total: 0
      },
      detailStats: {
        disponibles: 0,
        asignados: 0,
        usados: 0,
        total: 0,
        porTipo: []
      },
      availableYears: [],
      pagination: {
        page: 1,
        limit: 10,
        total: 0
      }
    }
  },
  mounted() {
    this.loadHologramas()
    this.loadAvailableYears()
    this.loadStats()
  },
  methods: {
    async loadHologramas() {
      this.loading = true
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_hologramas_list',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_codigo', valor: this.filters.codigo || null },
              { nombre: 'p_estado', valor: this.filters.estado || null },
              { nombre: 'p_tipo', valor: this.filters.tipo || null },
              { nombre: 'p_anio', valor: this.filters.anio || null },
              { nombre: 'p_tiene_qr', valor: this.filters.tieneQR || null },
              { nombre: 'p_limite', valor: this.pagination.limit },
              { nombre: 'p_offset', valor: (this.pagination.page - 1) * this.pagination.limit }
            ],
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success && response.data.eResponse.data.result) {
          this.hologramas = response.data.eResponse.data.result || []
          this.pagination.total = response.data.eResponse.data.result[0]?.total_registros || 0
          this.stats = {
            disponibles: response.data.eResponse.data.result.filter(h => h.estado === 'disponible').length,
            asignados: response.data.eResponse.data.result.filter(h => h.estado === 'asignado').length,
            usados: response.data.eResponse.data.result.filter(h => h.estado === 'usado').length,
            total: response.data.eResponse.data.result.length
          }
        }
      } catch (error) {
        console.error('Error cargando hologramas:', error)
        this.$toast?.error('Error al cargar los hologramas')
      } finally {
        this.loading = false
      }
    },

    async loadStats() {
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'sp_hologramas_estadisticas',
            Base: 'padron_licencias',
            Parametros: [],
            Tenant: 'public'
          }
        })

        if (response.data?.success && response.data?.data) {
          this.detailStats = response.data.eResponse.data.result[0] || {
            disponibles: 0,
            asignados: 0,
            usados: 0,
            total: 0,
            porTipo: []
          }
        }
      } catch (error) {
        console.error('Error cargando estadísticas:', error)
      }
    },

    async loadAvailableYears() {
      const currentYear = new Date().getFullYear()
      this.availableYears = []
      for (let year = currentYear - 5; year <= currentYear + 2; year++) {
        this.availableYears.push(year)
      }
    },

    async saveItem() {
      try {
        const isUpdate = this.currentItem.id
        const operation = isUpdate ? 'sp_hologramas_update' : 'sp_hologramas_create'

        const parametros = [
          { nombre: 'p_codigo', valor: this.currentItem.codigo },
          { nombre: 'p_tipo', valor: this.currentItem.tipo || 'licencia' },
          { nombre: 'p_estado', valor: this.currentItem.estado || 'disponible' },
          { nombre: 'p_anio', valor: this.currentItem.anio || new Date().getFullYear() },
          { nombre: 'p_asignado_a', valor: this.currentItem.asignado_a || null },
          { nombre: 'p_observaciones', valor: this.currentItem.observaciones || null },
          { nombre: 'p_generar_qr', valor: this.currentItem.generar_qr || false }
        ]

        if (isUpdate) {
          parametros.unshift({ nombre: 'p_id', valor: this.currentItem.id })
        }

        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: operation,
            Base: 'padron_licencias',
            Parametros: parametros,
            Tenant: 'public'
          }
        })

        if (response.data && response.data.eResponse.success) {
          await Swal.fire({
            icon: 'success',
            title: 'Éxito',
            text: isUpdate ? 'Holograma actualizado correctamente' : 'Holograma registrado correctamente',
            timer: 3000,
            showConfirmButton: false
          })

          this.closeModal()
          this.loadHologramas()
          this.loadStats()
        } else {
          throw new Error(response.data?.data?.[0]?.message || 'Error en la operación')
        }
      } catch (error) {
        console.error('Error guardando holograma:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message || 'Error al guardar el holograma',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async verifyHolograma(holograma) {
      try {
        const { value: codigoInput } = await Swal.fire({
          title: 'Verificar Holograma',
          text: `Ingrese el código del holograma: ${holograma.codigo}`,
          input: 'text',
          inputPlaceholder: 'Código del holograma...',
          showCancelButton: true,
          confirmButtonText: 'Verificar',
          cancelButtonText: 'Cancelar',
          inputValidator: (value) => {
            if (!value) {
              return 'Debe ingresar el código del holograma'
            }
          }
        })

        if (codigoInput) {
          const response = await this.$axios.post('/api/generic', {
            eRequest: {
              Operacion: 'sp_hologramas_verificar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_codigo', valor: codigoInput }
              ],
              Tenant: 'public'
            }
          })

          if (response.data?.success && response.data?.data?.[0]?.verificado) {
            await Swal.fire({
              icon: 'success',
              title: 'Verificación Exitosa',
              text: 'El holograma es auténtico y válido',
              timer: 3000,
              showConfirmButton: false
            })
          } else {
            await Swal.fire({
              icon: 'error',
              title: 'Verificación Fallida',
              text: 'El código del holograma no coincide o es inválido',
              timer: 5000,
              showConfirmButton: false
            })
          }
        }
      } catch (error) {
        console.error('Error verificando holograma:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: 'Error al verificar el holograma',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    async generateQRCodes() {
      const result = await Swal.fire({
        title: 'Generar Códigos QR',
        text: '¿Desea generar códigos QR para todos los hologramas que no los tengan?',
        icon: 'question',
        showCancelButton: true,
        confirmButtonColor: '#28a745',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, generar',
        cancelButtonText: 'Cancelar'
      })

      if (result.isConfirmed) {
        try {
          const response = await this.$axios.post('/api/generic', {
            eRequest: {
              Operacion: 'sp_hologramas_generar_qr',
              Base: 'padron_licencias',
              Parametros: [],
              Tenant: 'public'
            }
          })

          if (response.data?.success) {
            await Swal.fire({
              icon: 'success',
              title: 'QR Generados',
              text: `Se generaron ${response.data.eResponse.data.result?.[0]?.generados || 0} códigos QR`,
              timer: 3000,
              showConfirmButton: false
            })
            this.loadHologramas()
          }
        } catch (error) {
          console.error('Error generando QR:', error)
          await Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Error al generar los códigos QR',
            timer: 5000,
            showConfirmButton: false
          })
        }
      }
    },

    async deleteItem(holograma) {
      const result = await Swal.fire({
        title: '¿Está seguro?',
        text: `¿Desea eliminar el holograma: ${holograma.codigo}?`,
        icon: 'warning',
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#3085d6',
        confirmButtonText: 'Sí, eliminar',
        cancelButtonText: 'Cancelar'
      })

      if (result.isConfirmed) {
        try {
          const response = await this.$axios.post('/api/generic', {
            eRequest: {
              Operacion: 'sp_hologramas_delete',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: holograma.id }
              ],
              Tenant: 'public'
            }
          })

          if (response.data?.success) {
            await Swal.fire({
              icon: 'success',
              title: 'Eliminado',
              text: 'Holograma eliminado correctamente',
              timer: 3000,
              showConfirmButton: false
            })
            this.loadHologramas()
            this.loadStats()
          }
        } catch (error) {
          console.error('Error eliminando holograma:', error)
          await Swal.fire({
            icon: 'error',
            title: 'Error',
            text: 'Error al eliminar el holograma',
            timer: 5000,
            showConfirmButton: false
          })
        }
      }
    },

    editItem(holograma) {
      this.currentItem = { ...holograma }
      this.modalTitle = 'Editar Holograma'
      this.showModal = true
    },

    async asignarHolograma(holograma) {
      try {
        const { value: licenciaNumero } = await Swal.fire({
          title: 'Asignar Holograma',
          text: `Asignar holograma ${holograma.codigo} a licencia:`,
          input: 'text',
          inputPlaceholder: 'Número de licencia...',
          showCancelButton: true,
          confirmButtonText: 'Asignar',
          cancelButtonText: 'Cancelar',
          inputValidator: (value) => {
            if (!value) {
              return 'Debe ingresar el número de licencia'
            }
          }
        })

        if (licenciaNumero) {
          const response = await this.$axios.post('/api/generic', {
            eRequest: {
              Operacion: 'sp_hologramas_asignar',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id_holograma', valor: holograma.id },
                { nombre: 'p_numero_licencia', valor: licenciaNumero }
              ],
              Tenant: 'public'
            }
          })

          if (response.data?.success) {
            await Swal.fire({
              icon: 'success',
              title: 'Asignado',
              text: `Holograma asignado correctamente a la licencia ${licenciaNumero}`,
              timer: 3000,
              showConfirmButton: false
            })
            this.loadHologramas()
            this.loadStats()
          } else {
            throw new Error(response.data?.message || 'Error al asignar holograma')
          }
        }
      } catch (error) {
        console.error('Error asignando holograma:', error)
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: error.message || 'Error al asignar el holograma',
          timer: 5000,
          showConfirmButton: false
        })
      }
    },

    viewQR(holograma) {
      this.selectedHolograma = holograma
      this.showQRModal = true
    },

    downloadQR() {
      if (this.selectedHolograma?.qr_code) {
        const link = document.createElement('a')
        link.href = this.selectedHolograma.qr_code
        link.download = `holograma_${this.selectedHolograma.codigo}_qr.png`
        link.click()
      }
    },

    printQR() {
      if (this.selectedHolograma?.qr_code) {
        const printWindow = window.open('', '_blank')
        printWindow.document.write(`
          <html>
            <head>
              <title>QR Code - ${this.selectedHolograma.codigo}</title>
              <style>
                body { text-align: center; margin: 50px; }
                img { max-width: 300px; }
              </style>
            </head>
            <body>
              <h2>Holograma: ${this.selectedHolograma.codigo}</h2>
              <img src="${this.selectedHolograma.qr_code}" alt="QR Code">
            </body>
          </html>
        `)
        printWindow.document.close()
        printWindow.print()
      }
    },

    closeModal() {
      this.showModal = false
      this.currentItem = {
        codigo: '',
        tipo: 'licencia',
        estado: 'disponible',
        anio: new Date().getFullYear(),
        asignado_a: '',
        observaciones: '',
        generar_qr: true
      }
    },

    resetFilters() {
      this.filters = {
        codigo: '',
        estado: '',
        tipo: '',
        anio: '',
        tieneQR: ''
      }
      this.pagination.page = 1
      this.loadHologramas()
    },

    changePage(page) {
      this.pagination.page = page
      this.loadHologramas()
    },

    getPageNumbers() {
      const total = Math.ceil(this.pagination.total / this.pagination.limit)
      const current = this.pagination.page
      const pages = []

      for (let i = Math.max(1, current - 2); i <= Math.min(total, current + 2); i++) {
        pages.push(i)
      }

      return pages
    },

    getTipoClass(tipo) {
      const classes = {
        'licencia': 'badge bg-primary',
        'anuncio': 'badge bg-warning',
        'especial': 'badge bg-info'
      }
      return classes[tipo] || 'badge bg-secondary'
    },

    getEstadoClass(estado) {
      const classes = {
        'disponible': 'badge bg-success',
        'asignado': 'badge bg-warning',
        'usado': 'badge bg-danger',
        'cancelado': 'badge bg-secondary'
      }
      return classes[estado] || 'badge bg-light'
    },

    formatDate(date) {
      if (!date) return 'N/A'
      return new Date(date).toLocaleDateString('es-MX')
    }
  },

  watch: {
    showStatsModal(newVal) {
      if (newVal) {
        this.loadStats()
      }
    }
  }
}
</script>

<style scoped>
.container-fluid {
  background-color: #f8f9fa;
  min-height: 100vh;
}

.breadcrumb {
  background: none;
  padding: 0.75rem 1rem;
}

.breadcrumb-item a {
  text-decoration: none;
  color: #6c757d;
}

.breadcrumb-item.active {
  color: #495057;
  font-weight: 500;
}

.card {
  border: none;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border-radius: 0.5rem;
}

.card-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  font-weight: 600;
}

.table th {
  border-top: none;
  font-weight: 600;
  color: #495057;
  background-color: #f8f9fa;
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 123, 255, 0.075);
}

.btn {
  border-radius: 0.375rem;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.badge {
  font-size: 0.75em;
}

.modal-content {
  border: none;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.modal-header {
  background-color: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
}

.form-label {
  font-weight: 500;
  color: #495057;
}

.text-danger {
  color: #dc3545 !important;
}

.font-monospace {
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
}

.opacity-75 {
  opacity: 0.75;
}

.img-thumbnail {
  padding: 0.25rem;
  background-color: #fff;
  border: 1px solid #dee2e6;
  border-radius: 0.375rem;
}

@media (max-width: 768px) {
  .container-fluid {
    padding-left: 15px;
    padding-right: 15px;
  }

  .table-responsive {
    border: none;
  }

  .btn-sm {
    padding: 0.125rem 0.25rem;
    font-size: 0.75rem;
  }

  .badge {
    font-size: 0.65em;
  }
}

/* Animaciones para los QR codes */
.qr-fade-enter-active,
.qr-fade-leave-active {
  transition: opacity 0.3s;
}

.qr-fade-enter,
.qr-fade-leave-to {
  opacity: 0;
}

/* Estilos para hover en tarjetas de estadísticas */
.card:hover {
  transform: translateY(-2px);
  transition: transform 0.2s ease-in-out;
}

/* Estilos para el estado de carga */
.spinner-border {
  width: 2rem;
  height: 2rem;
}

/* Estilos para iconos con animación */
.fas {
  transition: transform 0.2s ease-in-out;
}

.btn:hover .fas {
  transform: scale(1.1);
}
</style>