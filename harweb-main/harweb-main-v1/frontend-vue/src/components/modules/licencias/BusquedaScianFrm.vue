<template>
  <div class="container-fluid p-0 h-100">
    <!-- Municipal Header -->
    <div class="municipal-header p-3 mb-0">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h1 class="h3 mb-1"><i class="fas fa-search me-2"></i>Búsqueda de Códigos SCIAN</h1>
          <p class="mb-0 opacity-75">Sistema de Clasificación Industrial de América del Norte</p>
        </div>
        <div class="text-white-50">
          <ol class="breadcrumb mb-0 bg-transparent p-0">
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Inicio</a></li>
            <li class="breadcrumb-item"><a href="#" class="text-white-50">Licencias</a></li>
            <li class="breadcrumb-item text-white active">Búsqueda SCIAN</li>
          </ol>
        </div>
      </div>
    </div>

    <!-- Controls -->
    <div class="municipal-controls border-bottom p-3">
      <div class="d-flex justify-content-between align-items-center">
        <div class="btn-group" role="group">
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-home"></i>
          </button>
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-search"></i>
          </button>
          <button type="button" class="btn btn-municipal-white">
            <i class="fas fa-list"></i>
          </button>
        </div>
      </div>
    </div>

    <!-- Main Content -->
    <div class="p-4">

    <!-- Formulario de búsqueda -->
    <div class="card mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">
          <i class="fas fa-filter me-2"></i>
          Filtros de Búsqueda SCIAN
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-3">
            <label for="codigoScian" class="form-label">Código SCIAN</label>
            <input
              type="text"
              class="form-control"
              id="codigoScian"
              v-model="codigoScian"
              @input="debounceSearch"
              @keyup.enter="buscarCodigos"
              placeholder="Ej: 462112"
              maxlength="10"
            >
          </div>
          <div class="col-md-6">
            <label for="descripcion" class="form-label">Descripción de Actividad</label>
            <input
              type="text"
              class="form-control"
              id="descripcion"
              v-model="descripcion"
              @input="debounceSearch"
              @keyup.enter="buscarCodigos"
              placeholder="Ingrese descripción de la actividad para buscar..."
              maxlength="255"
            >
          </div>
          <div class="col-md-3">
            <label for="nivel" class="form-label">Nivel SCIAN</label>
            <select
              id="nivel"
              class="form-select"
              v-model="nivel"
              @change="debounceSearch"
            >
              <option value="">Todos los niveles</option>
              <option value="1">1 - Sector</option>
              <option value="2">2 - Subsector</option>
              <option value="3">3 - Rama</option>
              <option value="4">4 - Subrama</option>
              <option value="5">5 - Clase</option>
            </select>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12 d-flex gap-2">
            <button
              type="button"
              class="btn btn-primary"
              @click="buscarCodigos"
              :disabled="buscando"
            >
              <i class="fas fa-search me-2"></i>
              {{ buscando ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              type="button"
              class="btn btn-success"
              @click="actualizarDatos"
              :disabled="buscando"
            >
              <i class="fas fa-sync-alt me-2"></i>
              {{ buscando ? 'Actualizando...' : 'Actualizar' }}
            </button>
            <button
              v-if="modoDesarrollo"
              type="button"
              class="btn btn-warning"
              @click="generarDatosSimulados"
            >
              <i class="fas fa-database me-2"></i>
              Datos Simulados
            </button>
            <button
              type="button"
              class="btn btn-outline-secondary"
              @click="limpiarFiltros"
            >
              <i class="fas fa-times me-2"></i>
              Limpiar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Resultados de búsqueda -->
    <div class="card mb-4">
      <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
        <h5 class="mb-0">
          <i class="fas fa-list me-2"></i>
          Resultados de Búsqueda
          <span v-if="totalRegistros > 0" class="badge bg-light text-dark ms-2">{{ totalRegistros }}</span>
        </h5>
        <div class="d-flex gap-2">
          <select
            v-model="limitePorPagina"
            class="form-select form-select-sm"
            @change="buscarCodigos"
            style="width: auto;"
          >
            <option value="10">10 por página</option>
            <option value="25">25 por página</option>
            <option value="50">50 por página</option>
            <option value="100">100 por página</option>
          </select>
        </div>
      </div>
      <div class="card-body">
        <div v-if="buscando" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2">Buscando códigos SCIAN...</p>
        </div>

        <div v-else-if="codigosScian.length === 0 && !primeraBusqueda" class="text-center py-4">
          <i class="fas fa-search fa-3x text-muted mb-3"></i>
          <p class="text-muted">No se encontraron códigos SCIAN con los criterios especificados</p>
        </div>

        <div v-else-if="primeraBusqueda" class="text-center py-4">
          <i class="fas fa-info-circle fa-3x text-info mb-3"></i>
          <p class="text-muted">Utilice los filtros de arriba para buscar códigos SCIAN</p>
        </div>

        <div v-else>
          <div class="table-responsive">
            <table class="table table-striped table-hover mb-0">
              <thead class="table-dark">
                <tr>
                  <th style="width: 100px;">Código SCIAN</th>
                  <th>Descripción</th>
                  <th style="width: 80px;">Nivel</th>
                  <th style="width: 100px;">Sector</th>
                  <th style="width: 80px;">Empresas</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="codigo in codigosScian"
                  :key="codigo.codigo_scian"
                  :class="{'table-primary': codigo === codigoSeleccionado}"
                  style="cursor: pointer;"
                  @click="seleccionarCodigo(codigo)"
                >
                  <td class="fw-bold">{{ codigo.codigo_scian }}</td>
                  <td>{{ codigo.descripcion }}</td>
                  <td class="text-center">
                    <span class="badge bg-secondary">{{ obtenerNombreNivel(codigo.nivel) }}</span>
                  </td>
                  <td>{{ codigo.sector || 'N/A' }}</td>
                  <td class="text-center">{{ codigo.total_empresas || 0 }}</td>
                  <td class="text-center">
                    <button
                      class="btn btn-sm btn-outline-primary"
                      @click.stop="verDetalleCodigo(codigo)"
                      title="Ver detalle"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="card-footer d-flex justify-content-between align-items-center">
            <small class="text-muted">
              Mostrando {{ ((paginaActual - 1) * limitePorPagina) + 1 }} a
              {{ Math.min(paginaActual * limitePorPagina, totalRegistros) }} de
              {{ totalRegistros }} registros
            </small>
            <nav aria-label="Paginación de resultados">
              <ul class="pagination pagination-sm mb-0">
                <li class="page-item" :class="{ disabled: paginaActual === 1 }">
                  <button class="page-link" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
                    <i class="fas fa-chevron-left"></i>
                  </button>
                </li>
                <li
                  v-for="pagina in paginasVisibles"
                  :key="pagina"
                  class="page-item"
                  :class="{ active: pagina === paginaActual }"
                >
                  <button class="page-link" @click="cambiarPagina(pagina)" v-if="typeof pagina === 'number'">{{ pagina }}</button>
                  <span class="page-link" v-else>{{ pagina }}</span>
                </li>
                <li class="page-item" :class="{ disabled: paginaActual === totalPaginas }">
                  <button class="page-link" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
                    <i class="fas fa-chevron-right"></i>
                  </button>
                </li>
              </ul>
            </nav>
          </div>
        </div>
      </div>
    </div>

    <!-- Panel de código seleccionado -->
    <div v-if="codigoSeleccionado" class="card mb-4">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">
          <i class="fas fa-check-circle me-2"></i>
          Código SCIAN Seleccionado
        </h5>
      </div>
      <div class="card-body">
        <div class="row">
          <div class="col-md-6">
            <div class="mb-2">
              <strong>Código SCIAN:</strong> {{ codigoSeleccionado.codigo_scian }}
            </div>
            <div class="mb-2">
              <strong>Nivel:</strong>
              <span class="badge bg-secondary">{{ obtenerNombreNivel(codigoSeleccionado.nivel) }}</span>
            </div>
            <div class="mb-2">
              <strong>Sector:</strong> {{ codigoSeleccionado.sector || 'N/A' }}
            </div>
          </div>
          <div class="col-md-6">
            <div class="mb-2">
              <strong>Descripción:</strong> {{ codigoSeleccionado.descripcion }}
            </div>
            <div class="mb-2">
              <strong>Empresas:</strong> {{ codigoSeleccionado.total_empresas || 0 }}
            </div>
            <div class="mb-2">
              <strong>Estado:</strong>
              <span class="badge bg-success" v-if="codigoSeleccionado.activo === 'S'">Activo</span>
              <span class="badge bg-danger" v-else>Inactivo</span>
            </div>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12 d-flex gap-2">
            <button
              class="btn btn-success"
              @click="confirmarSeleccion"
            >
              <i class="fas fa-check me-2"></i>
              Confirmar Selección
            </button>
            <button
              class="btn btn-outline-secondary"
              @click="limpiarSeleccion"
            >
              <i class="fas fa-times me-2"></i>
              Cancelar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Alertas -->
    <div v-if="alertMessage" :class="`alert alert-${alertType} alert-dismissible fade show`">
      <i :class="`fas ${alertType === 'success' ? 'fa-check-circle' : 'fa-exclamation-triangle'} me-2`"></i>
      {{ alertMessage }}
      <button type="button" class="btn-close" @click="clearAlert"></button>
    </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BusquedaScianFrm',
  data() {
    return {
      // Filtros de búsqueda
      codigoScian: '',
      descripcion: '',
      nivel: '',

      // Datos
      codigosScian: [],
      codigoSeleccionado: null,

      // Estados de UI
      buscando: false,
      primeraBusqueda: true,
      debounceTimer: null,
      modoDesarrollo: process.env.NODE_ENV === 'development',

      // Paginación
      paginaActual: 1,
      limitePorPagina: 25,
      totalRegistros: 0,

      // Alertas
      alertMessage: '',
      alertType: 'info',

      // Configuración API
      apiConfig: {
        url: 'http://localhost:8000/api/generic',
        tenant: 'guadalajara',
        base: 'padron_licencias'
      }
    }
  },
  computed: {
    totalPaginas() {
      return Math.ceil(this.totalRegistros / this.limitePorPagina);
    },
    paginasVisibles() {
      const total = this.totalPaginas;
      const actual = this.paginaActual;
      const paginas = [];

      if (total <= 7) {
        for (let i = 1; i <= total; i++) {
          paginas.push(i);
        }
      } else {
        if (actual <= 4) {
          for (let i = 1; i <= 5; i++) {
            paginas.push(i);
          }
          paginas.push('...');
          paginas.push(total);
        } else if (actual >= total - 3) {
          paginas.push(1);
          paginas.push('...');
          for (let i = total - 4; i <= total; i++) {
            paginas.push(i);
          }
        } else {
          paginas.push(1);
          paginas.push('...');
          for (let i = actual - 1; i <= actual + 1; i++) {
            paginas.push(i);
          }
          paginas.push('...');
          paginas.push(total);
        }
      }

      return paginas;
    }
  },

  async mounted() {
    // Obtener parámetros desde query params
    this.codigoScian = this.$route.query.codigo || ''
    this.descripcion = this.$route.query.descripcion || ''
    this.nivel = this.$route.query.nivel || ''

    // Si hay parámetros de query, realizar búsqueda inicial
    if (this.codigoScian || this.descripcion) {
      this.buscarCodigos()
    }
  },

  methods: {
    async buscarCodigos() {
      // Validar criterios mínimos de búsqueda
      if (!this.codigoScian && (!this.descripcion || this.descripcion.trim().length < 3)) {
        this.codigosScian = []
        this.totalRegistros = 0
        this.primeraBusqueda = true
        this.showAlert('Ingrese un código SCIAN o al menos 3 caracteres en la descripción', 'warning')
        return
      }

      this.buscando = true
      this.primeraBusqueda = false
      this.clearAlert()

      try {
        // Construir parámetros para el SP
        const params = {
          codigo_scian: this.codigoScian.trim() || null,
          descripcion: this.descripcion.trim() || null,
          nivel: this.nivel || null,
          activo: 'S',
          limite: this.limitePorPagina,
          offset: (this.paginaActual - 1) * this.limitePorPagina
        }

        // Request usando patrón eRequest/eResponse
        const requestBody = {
          eRequest: 'SP_BUSQUEDA_SCIAN_LIST',
          eData: {
            tenant: this.apiConfig.tenant,
            base: this.apiConfig.base,
            params: params
          }
        }

        console.log('Enviando request:', requestBody)

        const response = await fetch(this.apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        console.log('Response recibida:', data)

        if (data.eResponse && data.eResponse.success) {
          const records = data.eResponse.data || []
          console.log('Records encontrados:', records)

          this.codigosScian = records
          this.totalRegistros = records.length

          if (this.totalRegistros === 0) {
            this.showAlert('No se encontraron códigos SCIAN con los criterios especificados', 'info')
          } else {
            this.showAlert(`Se encontraron ${this.totalRegistros} código(s) SCIAN`, 'success')
          }
        } else {
          console.error('Error en eResponse:', data.eResponse?.error || data.eResponse?.message)
          this.codigosScian = []
          this.totalRegistros = 0
          this.showAlert(data.eResponse?.error || data.eResponse?.message || 'Error al buscar códigos SCIAN', 'danger')
        }

      } catch (error) {
        console.error('Error en buscarCodigos:', error)
        this.showAlert('Error de conexión al buscar códigos SCIAN', 'danger')
        this.codigosScian = []
        this.totalRegistros = 0
      } finally {
        this.buscando = false
      }
    },

    async actualizarDatos() {
      // Force refresh de los datos sin cambiar filtros
      if (this.codigoScian || (this.descripcion && this.descripcion.trim().length >= 3)) {
        this.showAlert('Actualizando datos desde el servidor...', 'info')
        // Reset paginación y forzar nueva búsqueda
        this.paginaActual = 1
        await this.buscarCodigos()
      } else {
        this.showAlert('Ingrese un código SCIAN o al menos 3 caracteres en la descripción', 'warning')
      }
    },

    cambiarPagina(nuevaPagina) {
      if (typeof nuevaPagina === 'number' && nuevaPagina >= 1 && nuevaPagina <= this.totalPaginas) {
        this.paginaActual = nuevaPagina;
        this.buscarCodigos();
      }
    },

    debounceSearch() {
      // Limpiar timer anterior
      if (this.debounceTimer) {
        clearTimeout(this.debounceTimer)
      }

      // Establecer nuevo timer
      this.debounceTimer = setTimeout(() => {
        // Reset paginación en nueva búsqueda
        this.paginaActual = 1
        this.buscarCodigos()
      }, 1000) // Buscar después de 1 segundo de inactividad
    },

    limpiarFiltros() {
      this.codigoScian = ''
      this.descripcion = ''
      this.nivel = ''
      this.codigosScian = []
      this.codigoSeleccionado = null
      this.primeraBusqueda = true
      // Reset paginación
      this.paginaActual = 1
      this.totalRegistros = 0
      this.clearAlert()
    },

    seleccionarCodigo(codigo) {
      this.codigoSeleccionado = codigo
      this.showAlert(`Código SCIAN seleccionado: ${codigo.codigo_scian}`, 'info')
    },

    limpiarSeleccion() {
      this.codigoSeleccionado = null
      this.showAlert('Selección cancelada', 'info')
    },

    confirmarSeleccion() {
      if (!this.codigoSeleccionado) return

      // Emitir evento para componente padre
      this.$emit('scian-seleccionado', this.codigoSeleccionado)

      // Mostrar confirmación
      this.showAlert(
        `Código SCIAN confirmado: ${this.codigoSeleccionado.codigo_scian} - ${this.codigoSeleccionado.descripcion}`,
        'success'
      )

      // Si es una ventana modal o popup, cerrarla
      if (this.$route.query.modal === 'true') {
        window.close()
      }
    },

    async verDetalleCodigo(codigo) {
      try {
        // Obtener detalle completo usando SP_BUSQUEDA_SCIAN_GET
        const requestBody = {
          eRequest: 'SP_BUSQUEDA_SCIAN_GET',
          eData: {
            tenant: this.apiConfig.tenant,
            base: this.apiConfig.base,
            params: {
              codigo_scian: codigo.codigo_scian
            }
          }
        }

        const response = await fetch(this.apiConfig.url, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(requestBody)
        })

        const data = await response.json()

        if (data.eResponse && data.eResponse.success && data.eResponse.data.length > 0) {
          const detalle = data.eResponse.data[0]
          const detalles = [
            `Código SCIAN: ${detalle.codigo_scian}`,
            `Descripción: ${detalle.descripcion}`,
            `Nivel: ${this.obtenerNombreNivel(detalle.nivel)}`,
            `Sector: ${detalle.desc_sector || detalle.sector || 'N/A'}`,
            `Subsector: ${detalle.desc_subsector || detalle.subsector || 'N/A'}`,
            `Rama: ${detalle.desc_rama || detalle.rama || 'N/A'}`,
            `Empresas: ${detalle.total_empresas || 0}`,
            `Licencias: ${detalle.total_licencias || 0}`,
            `Trámites: ${detalle.total_tramites || 0}`,
            `Estado: ${detalle.activo === 'S' ? 'Activo' : 'Inactivo'}`
          ].join('\n')

          alert(`Detalle Completo del Código SCIAN:\n\n${detalles}`)
        } else {
          // Fallback con datos básicos
          const detalles = [
            `Código SCIAN: ${codigo.codigo_scian}`,
            `Descripción: ${codigo.descripcion}`,
            `Nivel: ${this.obtenerNombreNivel(codigo.nivel)}`,
            `Sector: ${codigo.sector || 'N/A'}`,
            `Empresas: ${codigo.total_empresas || 0}`
          ].join('\n')

          alert(`Detalle del Código SCIAN:\n\n${detalles}`)
        }
      } catch (error) {
        console.error('Error al obtener detalle:', error)
        // Mostrar datos básicos como fallback
        const detalles = [
          `Código SCIAN: ${codigo.codigo_scian}`,
          `Descripción: ${codigo.descripcion}`,
          `Nivel: ${this.obtenerNombreNivel(codigo.nivel)}`
        ].join('\n')

        alert(`Detalle del Código SCIAN:\n\n${detalles}`)
      }
    },

    obtenerNombreNivel(nivel) {
      const niveles = {
        '1': 'Sector',
        '2': 'Subsector',
        '3': 'Rama',
        '4': 'Subrama',
        '5': 'Clase'
      }
      return niveles[nivel] || 'N/A'
    },

    showAlert(message, type = 'info') {
      this.alertMessage = message
      this.alertType = type

      // Auto-hide después de 5 segundos para success/info
      if (type === 'success' || type === 'info') {
        setTimeout(() => {
          this.clearAlert()
        }, 5000)
      }
    },

    clearAlert() {
      this.alertMessage = ''
      this.alertType = 'info'
    },

    // Método para generar datos simulados en desarrollo
    generarDatosSimulados() {
      if (!this.modoDesarrollo) return

      const scianSimulados = [
        {
          codigo_scian: '11',
          descripcion: 'Agricultura, cría y explotación de animales, aprovechamiento forestal, pesca y caza',
          nivel: '1',
          sector: '11',
          subsector: null,
          rama: null,
          subrama: null,
          clase: null,
          activo: 'S',
          total_empresas: 45
        },
        {
          codigo_scian: '111',
          descripcion: 'Agricultura',
          nivel: '2',
          sector: '11',
          subsector: '111',
          rama: null,
          subrama: null,
          clase: null,
          activo: 'S',
          total_empresas: 38
        },
        {
          codigo_scian: '1111',
          descripcion: 'Cultivo de granos y semillas oleaginosas',
          nivel: '3',
          sector: '11',
          subsector: '111',
          rama: '1111',
          subrama: null,
          clase: null,
          activo: 'S',
          total_empresas: 15
        },
        {
          codigo_scian: '11111',
          descripcion: 'Cultivo de soya',
          nivel: '4',
          sector: '11',
          subsector: '111',
          rama: '1111',
          subrama: '11111',
          clase: null,
          activo: 'S',
          total_empresas: 8
        },
        {
          codigo_scian: '111110',
          descripcion: 'Cultivo de soya',
          nivel: '5',
          sector: '11',
          subsector: '111',
          rama: '1111',
          subrama: '11111',
          clase: '111110',
          activo: 'S',
          total_empresas: 8
        },
        {
          codigo_scian: '46',
          descripcion: 'Comercio al por mayor',
          nivel: '1',
          sector: '46',
          subsector: null,
          rama: null,
          subrama: null,
          clase: null,
          activo: 'S',
          total_empresas: 234
        },
        {
          codigo_scian: '461',
          descripcion: 'Comercio al por mayor de abarrotes, alimentos, bebidas, hielo y tabaco',
          nivel: '2',
          sector: '46',
          subsector: '461',
          rama: null,
          subrama: null,
          clase: null,
          activo: 'S',
          total_empresas: 156
        },
        {
          codigo_scian: '4611',
          descripcion: 'Comercio al por mayor de abarrotes y alimentos',
          nivel: '3',
          sector: '46',
          subsector: '461',
          rama: '4611',
          subrama: null,
          clase: null,
          activo: 'S',
          total_empresas: 89
        },
        {
          codigo_scian: '46111',
          descripcion: 'Comercio al por mayor de abarrotes y conservas alimenticias',
          nivel: '4',
          sector: '46',
          subsector: '461',
          rama: '4611',
          subrama: '46111',
          clase: null,
          activo: 'S',
          total_empresas: 45
        },
        {
          codigo_scian: '461110',
          descripcion: 'Comercio al por mayor de abarrotes y conservas alimenticias',
          nivel: '5',
          sector: '46',
          subsector: '461',
          rama: '4611',
          subrama: '46111',
          clase: '461110',
          activo: 'S',
          total_empresas: 45
        }
      ]

      // Filtrar por criterios actuales si existen
      let scianFiltrados = scianSimulados

      if (this.codigoScian && this.codigoScian.trim()) {
        scianFiltrados = scianFiltrados.filter(scian =>
          scian.codigo_scian.includes(this.codigoScian.trim())
        )
      }

      if (this.descripcion && this.descripcion.trim()) {
        scianFiltrados = scianFiltrados.filter(scian =>
          scian.descripcion.toLowerCase().includes(this.descripcion.toLowerCase())
        )
      }

      if (this.nivel) {
        scianFiltrados = scianFiltrados.filter(scian =>
          scian.nivel === this.nivel
        )
      }

      this.codigosScian = scianFiltrados
      this.totalRegistros = scianFiltrados.length
      this.primeraBusqueda = false

      this.showAlert(`Datos simulados generados: ${this.totalRegistros} códigos SCIAN`, 'info')
    }
  },

  beforeUnmount() {
    // Limpiar timer si existe
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }
}
</script>

<style scoped>
.table th {
  border-top: none;
  font-weight: 500;
}

.card-header {
  font-weight: 500;
}

.badge {
  font-size: 0.75rem;
}

.btn:disabled {
  opacity: 0.65;
}

.alert {
  margin-top: 1rem;
}

.form-select:focus,
.form-control:focus {
  border-color: #86b7fe;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.table-hover tbody tr:hover {
  background-color: rgba(0, 0, 0, 0.075);
}

.table-primary {
  --bs-table-accent-bg: var(--bs-primary-bg-subtle);
  border-color: var(--bs-primary-border-subtle);
}

.spinner-border {
  width: 2rem;
  height: 2rem;
}

.table-responsive {
  max-height: 500px;
  overflow-y: auto;
}

.gap-2 {
  gap: 0.5rem;
}

.text-decoration-none:hover {
  text-decoration: underline !important;
}

.badge {
  font-size: 0.7rem;
  font-weight: 500;
}

.btn-warning {
  background-color: #ffc107;
  border-color: #ffc107;
  color: #000;
}

.btn-warning:hover {
  background-color: #ffca2c;
  border-color: #ffc720;
  color: #000;
}

.municipal-controls .btn-group .btn {
  border-radius: 0;
}

.municipal-controls .btn-group .btn:first-child {
  border-top-left-radius: 0.25rem;
  border-bottom-left-radius: 0.25rem;
}

.municipal-controls .btn-group .btn:last-child {
  border-top-right-radius: 0.25rem;
  border-bottom-right-radius: 0.25rem;
}

.fw-bold {
  font-weight: 600;
}

/* Estilos específicos para códigos SCIAN */
.codigo-scian {
  font-family: 'Courier New', monospace;
  font-weight: bold;
}

.nivel-badge {
  font-size: 0.8rem;
  padding: 0.25rem 0.5rem;
}

.sector-info {
  font-size: 0.9rem;
  color: #6c757d;
}

.empresas-count {
  font-weight: 500;
  color: #198754;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .table-responsive {
    font-size: 0.9rem;
  }

  .badge {
    font-size: 0.6rem;
  }

  .btn-sm {
    padding: 0.25rem 0.5rem;
    font-size: 0.75rem;
  }
}
</style>