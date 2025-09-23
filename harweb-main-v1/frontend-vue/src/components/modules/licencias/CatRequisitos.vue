<template>
  <div class="cat-requisitos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Requisitos</li>
      </ol>
    </nav>
    <h2>Mantenimiento a Requisitos</h2>
    <div class="mb-3 d-flex align-items-center">
      <input v-model="search" @input="onSearch" class="form-control mr-2" placeholder="Buscar requisito..." style="max-width: 350px;" />
      <button class="btn btn-primary ml-2" @click="openForm('create')">Agregar</button>
    </div>
    <table class="table table-striped table-hover">
      <thead>
        <tr>
          <th style="width: 80px">Número</th>
          <th>Descripción</th>
          <th style="width: 140px">Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="req in requisitos" :key="req.req">
          <td>{{ req.req }}</td>
          <td>{{ req.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-secondary mr-1" @click="openForm('edit', req)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteReq(req)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="requisitos.length === 0">
          <td colspan="3" class="text-center">No hay requisitos</td>
        </tr>
      </tbody>
    </table>
    <div class="mt-3">
      <button class="btn btn-outline-info" @click="printList"><i class="fa fa-print"></i> Imprimir listado</button>
    </div>

    <!-- Modal Form -->
    <div v-if="showForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h5 v-if="formMode==='create'">Agregar Requisito</h5>
          <h5 v-else>Editar Requisito</h5>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Número</label>
              <input v-model="form.req" :readonly="formMode==='edit'" type="number" class="form-control" required v-if="formMode==='edit'" />
              <span v-else class="form-text text-muted">Se asigna automáticamente</span>
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" type="text" class="form-control" required maxlength="255" />
            </div>
            <div class="d-flex justify-content-end">
              <button type="button" class="btn btn-secondary mr-2" @click="closeForm">Cancelar</button>
              <button type="submit" class="btn btn-success">Guardar</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal Confirm Delete -->
    <div v-if="showDelete" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h5>¿Eliminar requisito?</h5>
          <p>¿Está seguro de eliminar el requisito <b>{{ reqToDelete.descripcion }}</b>?</p>
          <div class="d-flex justify-content-end">
            <button class="btn btn-secondary mr-2" @click="showDelete=false">Cancelar</button>
            <button class="btn btn-danger" @click="confirmDelete">Eliminar</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Print -->
    <div v-if="showPrint" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h5>Listado de Requisitos</h5>
          <table class="table table-bordered">
            <thead>
              <tr><th>Número</th><th>Descripción</th></tr>
            </thead>
            <tbody>
              <tr v-for="req in requisitos" :key="req.req">
                <td>{{ req.req }}</td>
                <td>{{ req.descripcion }}</td>
              </tr>
            </tbody>
          </table>
          <div class="d-flex justify-content-end">
            <button class="btn btn-primary" @click="showPrint=false">Cerrar</button>
            <button class="btn btn-success ml-2" @click="doPrint">Imprimir</button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'CatRequisitosPage',
  data() {
    return {
      requisitos: [],
      search: '',
      showForm: false,
      formMode: 'create',
      form: { req: '', descripcion: '' },
      showDelete: false,
      reqToDelete: {},
      showPrint: false
    };
  },
  created() {
    this.loadRequisitos();
  },
  methods: {
    async loadRequisitos() {
      let payload = { eRequest: { module: 'cat_requisitos', action: 'list' } };
      let res = await this.$axios.post('/api/execute', payload);
      if (res.data.eResponse.success) {
        this.requisitos = res.data.eResponse.data;
      } else {
        this.$toast.error(res.data.eResponse.message || 'Error al cargar requisitos');
      }
    },
    onSearch() {
      if (!this.search) return this.loadRequisitos();
      let payload = { eRequest: { module: 'cat_requisitos', action: 'search', data: { descripcion: this.search } } };
      this.$axios.post('/api/execute', payload).then(res => {
        if (res.data.eResponse.success) {
          this.requisitos = res.data.eResponse.data;
        } else {
          this.$toast.error(res.data.eResponse.message || 'Error en búsqueda');
        }
      });
    },
    openForm(mode, req = null) {
      this.formMode = mode;
      if (mode === 'edit' && req) {
        this.form = { req: req.req, descripcion: req.descripcion };
      } else {
        this.form = { req: '', descripcion: '' };
      }
      this.showForm = true;
    },
    closeForm() {
      this.showForm = false;
    },
    async submitForm() {
      if (!this.form.descripcion) {
        this.$toast.error('La descripción es obligatoria');
        return;
      }
      let action = this.formMode === 'create' ? 'create' : 'update';
      let data = { descripcion: this.form.descripcion };
      if (action === 'update') data.req = this.form.req;
      let payload = { eRequest: { module: 'cat_requisitos', action, data } };
      let res = await this.$axios.post('/api/execute', payload);
      if (res.data.eResponse.success) {
        this.$toast.success('Guardado correctamente');
        this.showForm = false;
        this.loadRequisitos();
      } else {
        this.$toast.error(res.data.eResponse.message || 'Error al guardar');
      }
    },
    deleteReq(req) {
      this.reqToDelete = req;
      this.showDelete = true;
    },
    async confirmDelete() {
      let payload = { eRequest: { module: 'cat_requisitos', action: 'delete', data: { req: this.reqToDelete.req } } };
      let res = await this.$axios.post('/api/execute', payload);
      if (res.data.eResponse.success) {
        this.$toast.success('Eliminado correctamente');
        this.showDelete = false;
        this.loadRequisitos();
      } else {
        this.$toast.error(res.data.eResponse.message || 'Error al eliminar');
      }
    },
    printList() {
      this.showPrint = true;
    },
    doPrint() {
      window.print();
    }
  }
};
</script>

<style scoped>
.cat-requisitos-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.07);
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 100%;
  max-width: 500px;
}
.modal-container {
  background: #fff;
  border-radius: 6px;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}
</style>
