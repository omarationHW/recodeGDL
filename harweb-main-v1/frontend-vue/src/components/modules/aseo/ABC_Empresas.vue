<template>
  <div class="empresas-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Empresas</li>
      </ol>
    </nav>
    <h1>Catálogo de Empresas</h1>
    <div class="mb-3 d-flex justify-content-between align-items-center">
      <button class="btn btn-primary" @click="showForm('create')">Agregar Empresa</button>
      <input v-model="search.descripcion" class="form-control w-25" placeholder="Buscar por nombre..." @keyup.enter="fetchEmpresas" />
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>#</th>
          <th>Control</th>
          <th>Tipo</th>
          <th>Descripción</th>
          <th>Representante</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(empresa, idx) in empresas" :key="empresa.num_empresa + '-' + empresa.ctrol_emp">
          <td>{{ empresa.num_empresa }}</td>
          <td>{{ empresa.ctrol_emp }}</td>
          <td>{{ empresa.tipo_empresa }}</td>
          <td>{{ empresa.descripcion }}</td>
          <td>{{ empresa.representante }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="showForm('edit', empresa)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteEmpresa(empresa)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="empresas.length === 0">
          <td colspan="6" class="text-center">No hay empresas registradas.</td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Form -->
    <div v-if="modalOpen" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ formMode === 'create' ? 'Agregar Empresa' : 'Editar Empresa' }}</h5>
            <button type="button" class="btn-close" @click="closeForm"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="submitForm">
              <div class="mb-3">
                <label for="ctrol_emp" class="form-label">Tipo de Empresa</label>
                <select v-model="form.ctrol_emp" class="form-select" required>
                  <option v-for="tipo in tiposEmp" :key="tipo.ctrol_emp" :value="tipo.ctrol_emp">
                    {{ tipo.tipo_empresa }} - {{ tipo.descripcion }}
                  </option>
                </select>
              </div>
              <div class="mb-3">
                <label for="descripcion" class="form-label">Descripción</label>
                <input v-model="form.descripcion" type="text" class="form-control" required />
              </div>
              <div class="mb-3">
                <label for="representante" class="form-label">Representante</label>
                <input v-model="form.representante" type="text" class="form-control" required />
              </div>
              <div v-if="formMode === 'edit'" class="mb-3">
                <label for="num_empresa" class="form-label">Número de Empresa</label>
                <input v-model="form.num_empresa" type="number" class="form-control" readonly />
              </div>
              <div class="d-flex justify-content-end">
                <button type="submit" class="btn btn-success me-2">Guardar</button>
                <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>
    <!-- End Modal -->
  </div>
</template>

<script>
export default {
  name: 'EmpresasPage',
  data() {
    return {
      empresas: [],
      tiposEmp: [],
      search: {
        descripcion: ''
      },
      modalOpen: false,
      formMode: 'create',
      form: {
        num_empresa: null,
        ctrol_emp: '',
        descripcion: '',
        representante: ''
      }
    };
  },
  mounted() {
    this.fetchEmpresas();
    this.fetchTiposEmp();
  },
  methods: {
    async fetchEmpresas() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: this.search.descripcion ? 'search_empresas' : 'list_empresas',
          payload: this.search.descripcion ? { descripcion: this.search.descripcion } : {}
        });
        if (res.data.status === 'success') {
          this.empresas = res.data.data;
        } else {
          alert(res.data.message || 'Error al cargar empresas');
        }
      } catch (error) {
        alert('Error de conexión: ' + error.message);
      }
    },
    async fetchTiposEmp() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'list_tipos_emp'
        });
        if (res.data.status === 'success') {
          this.tiposEmp = res.data.data;
        } else {
          this.tiposEmp = [
            { ctrol_emp: 9, tipo_empresa: 'P', descripcion: 'Privada' },
            { ctrol_emp: 4, tipo_empresa: 'G', descripcion: 'Gobierno' }
          ];
        }
      } catch (error) {
        this.tiposEmp = [
          { ctrol_emp: 9, tipo_empresa: 'P', descripcion: 'Privada' },
          { ctrol_emp: 4, tipo_empresa: 'G', descripcion: 'Gobierno' }
        ];
      }
    },
    showForm(mode, empresa = null) {
      this.formMode = mode;
      if (mode === 'edit' && empresa) {
        this.form = { ...empresa };
      } else {
        this.form = {
          num_empresa: null,
          ctrol_emp: this.tiposEmp.length ? this.tiposEmp[0].ctrol_emp : '',
          descripcion: '',
          representante: ''
        };
      }
      this.modalOpen = true;
    },
    closeForm() {
      this.modalOpen = false;
    },
    async submitForm() {
      try {
        let action = this.formMode === 'create' ? 'create_empresa' : 'update_empresa';
        const res = await this.$axios.post('/api/execute', {
          action,
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.closeForm();
          this.fetchEmpresas();
        } else {
          alert(res.data.message || 'Error al guardar empresa');
        }
      } catch (error) {
        alert('Error de conexión: ' + error.message);
      }
    },
    async deleteEmpresa(empresa) {
      if (!confirm('¿Está seguro de eliminar esta empresa?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'delete_empresa',
          payload: {
            num_empresa: empresa.num_empresa,
            ctrol_emp: empresa.ctrol_emp
          }
        });
        if (res.data.status === 'success') {
          this.fetchEmpresas();
        } else {
          alert(res.data.message || 'No se pudo eliminar la empresa');
        }
      } catch (error) {
        alert('Error de conexión: ' + error.message);
      }
    }
  }
};
</script>

<style scoped>
.empresas-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-dialog {
  background: #fff;
  border-radius: 8px;
  min-width: 400px;
  max-width: 90vw;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
</style>
