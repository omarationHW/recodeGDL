<template>
  <div class="container-fluid py-4">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-4">
      <h1 class="h2 mb-0"><i class="fas fa-users me-2"></i>Empleados</h1>
      <div class="d-flex gap-2">
        <button class="btn btn-success" @click="actualizarDatos" title="Actualizar">
          <i class="fas fa-sync-alt me-2"></i>
          Actualizar
        </button>
        <button class="btn btn-primary" @click="mostrarModalAgregar">
          <i class="fas fa-plus me-2"></i>
          Nuevo
        </button>
      </div>
    </div>

    <!-- Barra de búsqueda -->
    <div class="row mb-4">
      <div class="col-md-6">
        <div class="input-group">
          <span class="input-group-text"><i class="fas fa-search"></i></span>
          <input 
            type="text" 
            class="form-control"
            placeholder="Buscar empleados..."
            v-model="filters.name"
            @input="aplicarFiltros"
          >
        </div>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-3"><i class="fas fa-clock me-2"></i>Cargando empleados...</p>
    </div>

    <!-- Empty state -->
    <div v-else-if="filteredEmployees.length === 0" class="text-center py-5">
      <div class="display-1 mb-3"><i class="fas fa-user-slash text-muted"></i></div>
      <h3>No hay empleados</h3>
      <p class="text-muted">Comienza agregando el primer empleado</p>
      <button class="btn btn-primary" @click="mostrarModalAgregar">
        <i class="fas fa-plus me-2"></i>
        Agregar empleado
      </button>
    </div>

    <!-- Tabla de empleados -->
    <div v-else class="card">
      <div class="card-header">
        <h5 class="card-title mb-0">Lista de Empleados</h5>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-striped table-hover mb-0">
            <thead class="table-light">
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Email</th>
                <th>Fecha Ingreso</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="employee in paginatedEmployees" :key="employee.id">
                <td><span class="badge bg-secondary">#{{ employee.employeeId }}</span></td>
                <td class="fw-medium">{{ employee.firstName }} {{ employee.lastName }}</td>
                <td>{{ employee.email }}</td>
                <td>{{ formatDate(employee.hireDate) }}</td>
                <td>
                  <div class="btn-group btn-group-sm" role="group">
                    <button 
                      type="button" 
                      class="btn btn-outline-dark" 
                      @click="verEmpleado(employee)" 
                      title="Ver"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button 
                      type="button" 
                      class="btn btn-outline-dark" 
                      @click="editarEmpleado(employee)" 
                      title="Editar"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                    <button 
                      type="button" 
                      class="btn btn-outline-dark" 
                      @click="eliminarEmpleado(employee)" 
                      title="Eliminar"
                    >
                      <i class="fas fa-trash"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
        
    <!-- Paginación -->
    <nav v-if="totalPages > 1" aria-label="Paginación de empleados" class="mt-4">
      <div class="d-flex justify-content-between align-items-center">
        <div class="text-muted">
          <i class="fas fa-info-circle me-2"></i>Mostrando {{ startRecord }} - {{ endRecord }} de {{ filteredEmployees.length }} empleados
        </div>
        <ul class="pagination mb-0">
          <li class="page-item" :class="{ disabled: currentPage === 1 }">
            <button 
              class="page-link" 
              @click="irAPagina(currentPage - 1)"
              :disabled="currentPage === 1"
            >
              <i class="fas fa-chevron-left"></i>
            </button>
          </li>
          
          <li class="page-item active">
            <span class="page-link">
              {{ currentPage }} / {{ totalPages }}
            </span>
          </li>
          
          <li class="page-item" :class="{ disabled: currentPage === totalPages }">
            <button 
              class="page-link" 
              @click="irAPagina(currentPage + 1)"
              :disabled="currentPage === totalPages"
            >
              <i class="fas fa-chevron-right"></i>
            </button>
          </li>
        </ul>
      </div>
    </nav>

    <!-- Modal de detalles -->
    <div v-if="showViewModal" class="modal fade show d-block" tabindex="-1" style="background: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title"><i class="fas fa-user-circle me-2"></i>Detalles del empleado</h5>
            <button type="button" class="btn-close" @click="cerrarModalVer"></button>
          </div>
          <div class="modal-body" v-if="selectedEmployee">
            <div class="row g-3">
              <div class="col-12">
                <div class="card">
                  <div class="card-body">
                    <h6 class="card-title"><i class="fas fa-id-card me-2"></i>Información Personal</h6>
                    <table class="table table-sm table-borderless">
                      <tbody>
                        <tr>
                          <td class="fw-bold">Nombre:</td>
                          <td>{{ selectedEmployee.firstName }} {{ selectedEmployee.lastName }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold">ID:</td>
                          <td><span class="badge bg-secondary">#{{ selectedEmployee.employeeId }}</span></td>
                        </tr>
                        <tr>
                          <td class="fw-bold">Email:</td>
                          <td>{{ selectedEmployee.email }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold">Departamento:</td>
                          <td>{{ selectedEmployee.department }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold">Fecha ingreso:</td>
                          <td>{{ formatDate(selectedEmployee.hireDate) }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalVer">
              <i class="fas fa-times me-2"></i>Cerrar
            </button>
            <button type="button" class="btn btn-warning" @click="editarEmpleado(selectedEmployee)">
              <i class="fas fa-edit me-2"></i>Editar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para agregar/editar -->
    <div v-if="showFormModal" class="modal fade show d-block" tabindex="-1" style="background: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i :class="editingEmployee ? 'fas fa-edit me-2' : 'fas fa-user-plus me-2'"></i>
              {{ editingEmployee ? 'Editar empleado' : 'Nuevo empleado' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModalFormulario"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarEmpleado">
              <div class="mb-3">
                <label class="form-label fw-bold">
                  <i class="fas fa-user me-2"></i>Nombre completo
                </label>
                <input 
                  type="text" 
                  class="form-control" 
                  v-model="employeeForm.nombre"
                  required
                  placeholder="Ej. Juan Pérez"
                >
              </div>
              
              <div class="mb-3">
                <label class="form-label fw-bold">
                  <i class="fas fa-envelope me-2"></i>Email
                </label>
                <input 
                  type="email" 
                  class="form-control" 
                  v-model="employeeForm.correo"
                  required
                  placeholder="juan@empresa.com"
                >
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarModalFormulario">
              <i class="fas fa-times me-2"></i>Cancelar
            </button>
            <button 
              type="button" 
              class="btn btn-primary" 
              @click="guardarEmpleado"
              :disabled="saving"
            >
              <span v-if="saving" class="spinner-border spinner-border-sm me-2"></span>
              <i v-else :class="editingEmployee ? 'fas fa-save me-2' : 'fas fa-plus me-2'"></i>
              {{ saving ? 'Guardando...' : (editingEmployee ? 'Actualizar' : 'Guardar') }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmpleadosListado',
  data() {
    return {
      employees: [],
      filteredEmployees: [],
      selectedEmployee: null,
      loading: true,
      
      // Modales
      showViewModal: false,
      showFormModal: false,
      
      // Filtros
      filters: {
        name: '',
        department: '',
        status: ''
      },
      
      // Ordenamiento
      sortField: 'name',
      sortDirection: 'asc',
      
      // Paginación
      currentPage: 1,
      itemsPerPage: 10,
      
      // CRUD
      editingEmployee: null,
      employeeForm: {
        nombre: '',
        correo: ''
      },
      saving: false
    }
  },
  
  computed: {
    paginatedEmployees() {
      const start = (this.currentPage - 1) * this.itemsPerPage
      const end = start + this.itemsPerPage
      return this.filteredEmployees.slice(start, end)
    },
    
    totalPages() {
      return Math.ceil(this.filteredEmployees.length / this.itemsPerPage)
    },
    
    startRecord() {
      return (this.currentPage - 1) * this.itemsPerPage + 1
    },
    
    endRecord() {
      const end = this.currentPage * this.itemsPerPage
      return end > this.filteredEmployees.length ? this.filteredEmployees.length : end
    },
    
    visiblePages() {
      const pages = []
      const start = Math.max(1, this.currentPage - 2)
      const end = Math.min(this.totalPages, this.currentPage + 2)
      
      for (let i = start; i <= end; i++) {
        pages.push(i)
      }
      return pages
    }
  },
  
  methods: {
    async cargarEmpleados() {
      this.loading = true
      try {
        const eRequest = {
          Operacion: 'empleados_mantener', // Nuevo SP
          Base: 'licencias',
          Parametros: [
            { nombre: 'operacion', valor: 0, tipo: 'integer' }, // 0 = Consultar
            { nombre: 'id', valor: 0, tipo: 'integer' }, // 0 = Todos los registros
            { nombre: 'nombre', valor: null, tipo: 'string' }, // NULL para consulta
            { nombre: 'correo', valor: null, tipo: 'string' } // NULL para consulta
          ],
          Tenant: 'guadalajara'
        }
        
        console.log('🚀 Cargando empleados desde la API')
        
        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })
        
        if (response.data.eResponse && response.data.eResponse.success) {
          const apiData = response.data.eResponse.data.result || []
          
          this.employees = apiData.map((emp, index) => {
            const nombreCompleto = emp.nombre || ''
            const partesNombre = nombreCompleto.split(' ')
            const firstName = partesNombre[0] || ''
            const lastName = partesNombre.slice(1).join(' ') || ''
            
            return {
              id: emp.id,
              firstName: firstName,
              lastName: lastName,
              employeeId: `EMP${String(emp.id).padStart(3, '0')}`,
              email: emp.correo || '',
              phone: 'No registrado',
              department: 'licencias',
              position: 'Empleado',
              hireDate: emp.created_at?.split(' ')[0] || '',
              status: 'activo'
            }
          })
          
          console.log(`✅ ${this.employees.length} empleados cargados desde la API`)
        } else {
          throw new Error('API no devolvió datos válidos')
        }
        
        this.aplicarFiltros()
        
      } catch (error) {
        console.error('❌ Error loading employees:', error)
        this.employees = []
        this.aplicarFiltros()
      } finally {
        this.loading = false
      }
    },
    
    async guardarEmpleado() {
      if (!this.employeeForm.nombre || !this.employeeForm.correo) {
        alert('Por favor complete todos los campos requeridos')
        return
      }
      
      this.saving = true
      try {
        // Parámetros para el nuevo SP: _operacion, _id, _nombre, _correo
        const parametros = [
          { nombre: 'operacion', valor: 1, tipo: 'integer' }, // 1 = Insert/Update
          { nombre: 'id', valor: this.editingEmployee ? this.editingEmployee.id : 0, tipo: 'integer' },
          { nombre: 'nombre', valor: this.employeeForm.nombre, tipo: 'string' },
          { nombre: 'correo', valor: this.employeeForm.correo, tipo: 'string' }
        ]
        
        const eRequest = {
          Operacion: 'empleados_mantener', // Nuevo SP
          Base: 'licencias',
          Parametros: parametros,
          Tenant: 'guadalajara'
        }
        
        console.log(`🚀 ${this.editingEmployee ? 'Actualizando' : 'Creando'} empleado:`, parametros)
        console.log('📋 eRequest completo:', JSON.stringify(eRequest, null, 2))
        
        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })
        
        console.log('📋 Response recibida:', response.data)
        
        if (response.data.eResponse && response.data.eResponse.success) {
          console.log('✅ Empleado guardado correctamente')
          // Cerrar modal
          this.cerrarModalFormulario()
          await this.cargarEmpleados()
        } else {
          throw new Error(response.data.eResponse?.message || 'Error al guardar empleado')
        }
        
      } catch (error) {
        console.error('❌ Error saving employee:', error)
        console.error('❌ Error response data:', error.response?.data)
        console.error('❌ Error status:', error.response?.status)
        
        let errorMessage = 'Error desconocido'
        if (error.response?.data?.eResponse?.message) {
          errorMessage = error.response.data.eResponse.message
        } else if (error.message) {
          errorMessage = error.message
        }
        
        alert('Error al guardar empleado: ' + errorMessage)
      } finally {
        this.saving = false
      }
    },
    
    async eliminarEmpleado(employee) {
      console.log('🗑️ Eliminar empleado:', employee)
      if (!confirm(`¿Está seguro de eliminar al empleado "${employee.firstName} ${employee.lastName}"?`)) {
        return
      }
      
      try {
        // Parámetros para eliminar: _operacion=2, _id, _nombre=null, _correo=null
        const eRequest = {
          Operacion: 'empleados_mantener',
          Base: 'licencias',
          Parametros: [
            { nombre: 'operacion', valor: 2, tipo: 'integer' }, // 2 = Eliminar
            { nombre: 'id', valor: employee.id, tipo: 'integer' },
            { nombre: 'nombre', valor: null, tipo: 'string' },
            { nombre: 'correo', valor: null, tipo: 'string' }
          ],
          Tenant: 'guadalajara'
        }
        
        console.log('🚀 Eliminando empleado:', employee.id)
        
        const response = await this.$axios.post('/api/generic', {
          eRequest: eRequest
        })
        
        if (response.data.eResponse && response.data.eResponse.success) {
          console.log('✅ Empleado eliminado correctamente')
          await this.cargarEmpleados()
        } else {
          throw new Error(response.data.eResponse?.message || 'Error al eliminar empleado')
        }
        
      } catch (error) {
        console.error('❌ Error deleting employee:', error)
        alert('Error al eliminar empleado: ' + error.message)
      }
    },
    
    mostrarModalAgregar() {
      console.log('➕ Mostrar modal agregar empleado')
      this.editingEmployee = null
      this.resetearFormulario()
      this.showFormModal = true
    },
    
    resetearFormulario() {
      this.employeeForm = {
        nombre: '',
        correo: ''
      }
    },
    
    aplicarFiltros() {
      this.filteredEmployees = this.employees.filter(employee => {
        const matchesName = !this.filters.name || 
          (employee.firstName + ' ' + employee.lastName)
            .toLowerCase()
            .includes(this.filters.name.toLowerCase())
        
        const matchesDepartment = !this.filters.department || 
          employee.department === this.filters.department
        
        const matchesStatus = !this.filters.status || 
          employee.status === this.filters.status
        
        return matchesName && matchesDepartment && matchesStatus
      })
      
      this.ordenarEmpleados()
      this.currentPage = 1
    },
    
    limpiarFiltros() {
      this.filters = {
        name: '',
        department: '',
        status: ''
      }
      this.aplicarFiltros()
    },
    
    ordenarPor(field) {
      if (this.sortField === field) {
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc'
      } else {
        this.sortField = field
        this.sortDirection = 'asc'
      }
      this.ordenarEmpleados()
    },
    
    ordenarEmpleados() {
      this.filteredEmployees.sort((a, b) => {
        let aVal = a[this.sortField]
        let bVal = b[this.sortField]
        
        if (this.sortField === 'name') {
          aVal = a.firstName + ' ' + a.lastName
          bVal = b.firstName + ' ' + b.lastName
        }
        
        if (typeof aVal === 'string') {
          aVal = aVal.toLowerCase()
          bVal = bVal.toLowerCase()
        }
        
        if (this.sortDirection === 'asc') {
          return aVal > bVal ? 1 : -1
        } else {
          return aVal < bVal ? 1 : -1
        }
      })
    },
    
    irAPagina(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
      }
    },
    
    verEmpleado(employee) {
      console.log('👁️ Ver empleado:', employee)
      this.selectedEmployee = employee
      this.showViewModal = true
    },
    
    cerrarModalVer() {
      this.showViewModal = false
      this.selectedEmployee = null
    },
    
    editarEmpleado(employee) {
      console.log('✏️ Editar empleado:', employee)
      this.editingEmployee = employee
      this.employeeForm = {
        nombre: `${employee.firstName} ${employee.lastName}`.trim(),
        correo: employee.email
      }
      
      // Cerrar modal de detalles si está abierto
      this.showViewModal = false
      
      // Mostrar modal de edición
      this.showFormModal = true
    },
    
    cerrarModalFormulario() {
      this.showFormModal = false
      this.editingEmployee = null
      this.resetearFormulario()
    },
    
    imprimirReporte() {
      window.print()
    },
    
    async actualizarDatos() {
      console.log('🔄 Actualizando datos de empleados...')
      await this.cargarEmpleados()
    },
    
    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    }
  },
  
  mounted() {
    console.log('🎯 EmpleadosListado component mounted')
    this.cargarEmpleados()
  }
}
</script>

<style scoped>
/* Solo estilos mínimos necesarios para los modales personalizados */
.modal.show.d-block {
  display: block !important;
}
</style>