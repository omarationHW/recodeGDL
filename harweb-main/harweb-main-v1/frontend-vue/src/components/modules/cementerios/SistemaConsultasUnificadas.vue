<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #007bff !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center mb-3">
          <div class="bg-primary bg-opacity-10 rounded-3 p-3 me-3">
            <i class="fas fa-search fa-2x text-primary"></i>
          </div>
          <div>
            <h1 class="h3 fw-bold text-dark mb-1">
              <span class="badge bg-danger me-2" style="font-size: 0.6em;">NUEVO</span>
              Sistema de Consultas Unificadas
            </h1>
            <p class="text-muted mb-0">Búsqueda inteligente multifiltro para servicios de cementerios</p>
          </div>
        </div>

        <div class="alert alert-primary" role="alert">
          <div class="d-flex align-items-center">
            <i class="fas fa-magic me-2"></i>
            <div>
              <strong>🆕 Sistema Moderno de Búsquedas</strong>
              <p class="mb-0 small">
                Reemplaza múltiples sistemas obsoletos con algoritmos avanzados de búsqueda fonética y filtros combinados.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Tabs -->
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-light border-0 p-0">
        <ul class="nav nav-tabs border-0" id="consultasTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active fw-semibold px-4 py-3 border-0"
                    id="busqueda-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#busqueda"
                    type="button"
                    role="tab">
              <i class="fas fa-search me-2"></i>Búsqueda Universal
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold px-4 py-3 border-0"
                    id="filtros-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#filtros"
                    type="button"
                    role="tab">
              <i class="fas fa-filter me-2"></i>Filtros Avanzados
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold px-4 py-3 border-0"
                    id="resultados-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#resultados"
                    type="button"
                    role="tab">
              <i class="fas fa-list me-2"></i>Vista Integral
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold px-4 py-3 border-0"
                    id="exportacion-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#exportacion"
                    type="button"
                    role="tab">
              <i class="fas fa-download me-2"></i>Exportación
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body p-4">
        <div class="tab-content" id="consultasTabContent">
          <!-- Tab 1: Búsqueda Universal -->
          <div class="tab-pane fade show active" id="busqueda" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-search me-2"></i>Búsqueda Inteligente Multifiltro
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <label class="form-label fw-semibold">Buscar por cualquier criterio:</label>
                      <div class="input-group input-group-lg">
                        <span class="input-group-text bg-primary text-white">
                          <i class="fas fa-search"></i>
                        </span>
                        <input type="text"
                               class="form-control"
                               placeholder="RCM, nombre completo, folio, ubicación..."
                               v-model="searchQuery">
                        <button class="btn btn-primary" type="button">
                          <i class="fas fa-search me-1"></i>Buscar
                        </button>
                      </div>
                      <div class="form-text">
                        <i class="fas fa-info-circle me-1"></i>
                        Búsqueda fonética activada - encuentra nombres similares automáticamente
                      </div>
                    </div>

                    <div class="row g-3">
                      <div class="col-md-4">
                        <label class="form-label">Tipo de búsqueda:</label>
                        <select class="form-select" v-model="searchType">
                          <option value="universal">🔍 Universal (Todos los campos)</option>
                          <option value="rcm">📋 Registro Civil Municipal</option>
                          <option value="nombre">👤 Por Nombre</option>
                          <option value="folio">📄 Por Folio</option>
                          <option value="ubicacion">📍 Por Ubicación</option>
                        </select>
                      </div>
                      <div class="col-md-4">
                        <label class="form-label">Algoritmo:</label>
                        <select class="form-select" v-model="algorithm">
                          <option value="exacto">Coincidencia exacta</option>
                          <option value="fonetico">Búsqueda fonética</option>
                          <option value="similar">Nombres similares</option>
                          <option value="inteligente">Inteligente (combinado)</option>
                        </select>
                      </div>
                      <div class="col-md-4">
                        <label class="form-label">Resultados por página:</label>
                        <select class="form-select" v-model="pageSize">
                          <option value="10">10 resultados</option>
                          <option value="25">25 resultados</option>
                          <option value="50">50 resultados</option>
                          <option value="100">100 resultados</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-bookmark me-2"></i>Búsquedas Guardadas
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="list-group list-group-flush">
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex justify-content-between align-items-center">
                          <small class="text-muted">Servicios vencidos</small>
                          <button class="btn btn-sm btn-outline-info">
                            <i class="fas fa-play"></i>
                          </button>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex justify-content-between align-items-center">
                          <small class="text-muted">Panteón Municipal</small>
                          <button class="btn btn-sm btn-outline-info">
                            <i class="fas fa-play"></i>
                          </button>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex justify-content-between align-items-center">
                          <small class="text-muted">Pagos pendientes</small>
                          <button class="btn btn-sm btn-outline-info">
                            <i class="fas fa-play"></i>
                          </button>
                        </div>
                      </div>
                    </div>
                    <button class="btn btn-info btn-sm w-100 mt-2">
                      <i class="fas fa-save me-1"></i>Guardar búsqueda actual
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab 2: Filtros Avanzados -->
          <div class="tab-pane fade" id="filtros" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-sliders-h me-2"></i>Filtros de Servicios
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-12">
                        <label class="form-label fw-semibold">Tipo de Servicio:</label>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="inhumacion">
                          <label class="form-check-label" for="inhumacion">Inhumación</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="exhumacion">
                          <label class="form-check-label" for="exhumacion">Exhumación</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="cremacion">
                          <label class="form-check-label" for="cremacion">Cremación</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="mantenimiento">
                          <label class="form-check-label" for="mantenimiento">Mantenimiento</label>
                        </div>
                      </div>
                      <div class="col-6">
                        <label class="form-label">Fecha desde:</label>
                        <input type="date" class="form-control" v-model="fechaDesde">
                      </div>
                      <div class="col-6">
                        <label class="form-label">Fecha hasta:</label>
                        <input type="date" class="form-control" v-model="fechaHasta">
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-map-marker-alt me-2"></i>Filtros de Ubicación
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-12">
                        <label class="form-label">Panteón:</label>
                        <select class="form-select" v-model="panteon">
                          <option value="">Todos los panteones</option>
                          <option value="municipal">Panteón Municipal</option>
                          <option value="belen">Panteón Belén</option>
                          <option value="reforma">Panteón Reforma</option>
                          <option value="americana">Panteón Americana</option>
                        </select>
                      </div>
                      <div class="col-6">
                        <label class="form-label">Sección:</label>
                        <input type="text" class="form-control" placeholder="A, B, C..." v-model="seccion">
                      </div>
                      <div class="col-6">
                        <label class="form-label">Lote:</label>
                        <input type="text" class="form-control" placeholder="Número de lote" v-model="lote">
                      </div>
                      <div class="col-12">
                        <label class="form-label">Estado del servicio:</label>
                        <select class="form-select" v-model="estado">
                          <option value="">Todos los estados</option>
                          <option value="activo">Activo</option>
                          <option value="vencido">Vencido</option>
                          <option value="pagado">Pagado</option>
                          <option value="pendiente">Pendiente</option>
                        </select>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4 text-center">
              <button class="btn btn-primary btn-lg me-2">
                <i class="fas fa-filter me-1"></i>Aplicar Filtros
              </button>
              <button class="btn btn-outline-secondary btn-lg">
                <i class="fas fa-eraser me-1"></i>Limpiar Filtros
              </button>
            </div>
          </div>

          <!-- Tab 3: Vista Integral -->
          <div class="tab-pane fade" id="resultados" role="tabpanel">
            <div class="card border-dark border-opacity-25">
              <div class="card-header bg-dark bg-opacity-10">
                <h5 class="fw-bold mb-0 text-dark">
                  <i class="fas fa-table me-2"></i>Resultados de Búsqueda - Vista Integral
                </h5>
              </div>
              <div class="card-body">
                <div class="table-responsive">
                  <table class="table table-hover table-striped">
                    <thead class="table-dark">
                      <tr>
                        <th>Folio</th>
                        <th>RCM</th>
                        <th>Nombre Completo</th>
                        <th>Servicio</th>
                        <th>Ubicación</th>
                        <th>Fecha</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="resultado in resultados" :key="resultado.id">
                        <td><span class="badge bg-primary">{{ resultado.folio }}</span></td>
                        <td>{{ resultado.rcm }}</td>
                        <td>
                          <strong>{{ resultado.nombre }}</strong>
                          <br><small class="text-muted">{{ resultado.fecha_nacimiento }}</small>
                        </td>
                        <td>
                          <span :class="`badge bg-${getServiceColor(resultado.tipo_servicio)}`">
                            {{ resultado.tipo_servicio }}
                          </span>
                        </td>
                        <td>
                          <small>
                            {{ resultado.panteon }}<br>
                            Sec: {{ resultado.seccion }} Lote: {{ resultado.lote }}
                          </small>
                        </td>
                        <td>{{ formatDate(resultado.fecha_servicio) }}</td>
                        <td>
                          <span :class="`badge bg-${getStatusColor(resultado.estado)}`">
                            {{ resultado.estado }}
                          </span>
                        </td>
                        <td>
                          <div class="btn-group btn-group-sm">
                            <button class="btn btn-outline-primary" title="Ver detalles">
                              <i class="fas fa-eye"></i>
                            </button>
                            <button class="btn btn-outline-success" title="Historial">
                              <i class="fas fa-history"></i>
                            </button>
                            <button class="btn btn-outline-info" title="Documentos">
                              <i class="fas fa-file-alt"></i>
                            </button>
                          </div>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <!-- Paginación -->
                <nav aria-label="Navegación de resultados" class="mt-3">
                  <ul class="pagination justify-content-center">
                    <li class="page-item">
                      <a class="page-link" href="#" aria-label="Anterior">
                        <span aria-hidden="true">&laquo;</span>
                      </a>
                    </li>
                    <li class="page-item active"><a class="page-link" href="#">1</a></li>
                    <li class="page-item"><a class="page-link" href="#">2</a></li>
                    <li class="page-item"><a class="page-link" href="#">3</a></li>
                    <li class="page-item">
                      <a class="page-link" href="#" aria-label="Siguiente">
                        <span aria-hidden="true">&raquo;</span>
                      </a>
                    </li>
                  </ul>
                </nav>
              </div>
            </div>
          </div>

          <!-- Tab 4: Exportación -->
          <div class="tab-pane fade" id="exportacion" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-file-export me-2"></i>Exportación Flexible
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <label class="form-label fw-semibold">Formato de exportación:</label>
                      <select class="form-select" v-model="exportFormat">
                        <option value="excel">📊 Excel (.xlsx)</option>
                        <option value="pdf">📄 PDF</option>
                        <option value="csv">📋 CSV</option>
                        <option value="json">🔧 JSON</option>
                      </select>
                    </div>

                    <div class="mb-3">
                      <label class="form-label fw-semibold">Campos a incluir:</label>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_folio" checked>
                        <label class="form-check-label" for="incluir_folio">Folio</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_rcm" checked>
                        <label class="form-check-label" for="incluir_rcm">RCM</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_nombre" checked>
                        <label class="form-check-label" for="incluir_nombre">Nombre completo</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_servicio" checked>
                        <label class="form-check-label" for="incluir_servicio">Tipo de servicio</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_ubicacion" checked>
                        <label class="form-check-label" for="incluir_ubicacion">Ubicación</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_fechas">
                        <label class="form-check-label" for="incluir_fechas">Fechas de servicio</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="incluir_pagos">
                        <label class="form-check-label" for="incluir_pagos">Información de pagos</label>
                      </div>
                    </div>

                    <button class="btn btn-success w-100">
                      <i class="fas fa-download me-1"></i>Exportar Resultados
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-lg-6">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-chart-bar me-2"></i>Estadísticas de Búsqueda
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3 text-center">
                      <div class="col-6">
                        <div class="border rounded p-3">
                          <h3 class="text-primary mb-1">{{ totalResults }}</h3>
                          <small class="text-muted">Total encontrados</small>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="border rounded p-3">
                          <h3 class="text-success mb-1">{{ activeServices }}</h3>
                          <small class="text-muted">Servicios activos</small>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="border rounded p-3">
                          <h3 class="text-warning mb-1">{{ pendingPayments }}</h3>
                          <small class="text-muted">Pagos pendientes</small>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="border rounded p-3">
                          <h3 class="text-info mb-1">{{ searchTime }}</h3>
                          <small class="text-muted">Tiempo (ms)</small>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <h6 class="fw-semibold mb-2">Distribución por panteón:</h6>
                      <div class="progress mb-1" style="height: 6px;">
                        <div class="progress-bar bg-primary" style="width: 45%"></div>
                        <div class="progress-bar bg-success" style="width: 25%"></div>
                        <div class="progress-bar bg-warning" style="width: 20%"></div>
                        <div class="progress-bar bg-info" style="width: 10%"></div>
                      </div>
                      <small class="text-muted">
                        Municipal (45%) • Belén (25%) • Reforma (20%) • Americana (10%)
                      </small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue'

export default {
  name: 'SistemaConsultasUnificadas',
  setup() {
    // Estados reactivos para búsqueda
    const searchQuery = ref('')
    const searchType = ref('universal')
    const algorithm = ref('inteligente')
    const pageSize = ref('25')

    // Estados reactivos para filtros
    const fechaDesde = ref('')
    const fechaHasta = ref('')
    const panteon = ref('')
    const seccion = ref('')
    const lote = ref('')
    const estado = ref('')

    // Estados reactivos para exportación
    const exportFormat = ref('excel')

    // Estados reactivos para estadísticas
    const totalResults = ref(1247)
    const activeServices = ref(892)
    const pendingPayments = ref(156)
    const searchTime = ref(245)

    // Datos de ejemplo para resultados
    const resultados = ref([
      {
        id: 1,
        folio: 'CEM-2024-001',
        rcm: 'RC123456789',
        nombre: 'Juan Pérez García',
        fecha_nacimiento: '1945-03-15',
        tipo_servicio: 'Inhumación',
        panteon: 'Municipal',
        seccion: 'A',
        lote: '15',
        fecha_servicio: '2024-01-15',
        estado: 'Activo'
      },
      {
        id: 2,
        folio: 'CEM-2024-002',
        rcm: 'RC987654321',
        nombre: 'María Rodríguez López',
        fecha_nacimiento: '1952-07-22',
        tipo_servicio: 'Mantenimiento',
        panteon: 'Belén',
        seccion: 'B',
        lote: '32',
        fecha_servicio: '2024-02-10',
        estado: 'Pendiente'
      }
    ])

    // Métodos utilitarios
    const getServiceColor = (servicio) => {
      const colors = {
        'Inhumación': 'dark',
        'Exhumación': 'warning',
        'Cremación': 'danger',
        'Mantenimiento': 'info'
      }
      return colors[servicio] || 'secondary'
    }

    const getStatusColor = (estado) => {
      const colors = {
        'Activo': 'success',
        'Pendiente': 'warning',
        'Vencido': 'danger',
        'Pagado': 'primary'
      }
      return colors[estado] || 'secondary'
    }

    const formatDate = (date) => {
      return new Date(date).toLocaleDateString('es-ES')
    }

    return {
      searchQuery,
      searchType,
      algorithm,
      pageSize,
      fechaDesde,
      fechaHasta,
      panteon,
      seccion,
      lote,
      estado,
      exportFormat,
      totalResults,
      activeServices,
      pendingPayments,
      searchTime,
      resultados,
      getServiceColor,
      getStatusColor,
      formatDate
    }
  }
}
</script>

<style scoped>
.nav-tabs .nav-link {
  color: #6c757d;
  border: none;
  border-bottom: 3px solid transparent;
  transition: all 0.3s ease;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #dee2e6;
  background-color: #f8f9fa;
}

.nav-tabs .nav-link.active {
  color: #495057;
  background-color: #fff;
  border-bottom-color: #007bff;
}

.card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 123, 255, 0.1);
}

.btn-group-sm .btn {
  font-size: 0.75rem;
}

.progress {
  border-radius: 10px;
}

.form-check-input:checked {
  background-color: #007bff;
  border-color: #007bff;
}

.badge {
  font-size: 0.75em;
}

.input-group-lg .form-control {
  font-size: 1.1rem;
}

.pagination .page-link {
  color: #007bff;
  border: none;
  margin: 0 2px;
  border-radius: 50px;
}

.pagination .page-item.active .page-link {
  background-color: #007bff;
  border-color: #007bff;
}
</style>