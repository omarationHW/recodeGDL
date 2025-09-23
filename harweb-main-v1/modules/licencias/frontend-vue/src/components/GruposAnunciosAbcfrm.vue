<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Grupos de Anuncios</li>
      </ol>
    </nav>
    <h2 class="mb-4">Mantenimiento a Grupos de Anuncios</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="onSearch">
          <div class="form-row align-items-center">
            <div class="col-auto">
              <label for="searchDescripcion" class="col-form-label">Grupo</label>
            </div>
            <div class="col">
              <input type="text" v-model="search.descripcion" id="searchDescripcion" class="form-control" placeholder="Buscar por descripción..." @input="onSearch" />
            </div>
            <div class="col-auto">
              <button type="button" class="btn btn-primary" @click="onAdd" :disabled="formMode !== ''">Agregar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="card mb-3">
      <div class="card-body p-0">
        <table class="table table-hover mb-0">
          <thead class="thead-light">
            <tr>
              <th style="width: 80px;">ID</th>
              <th>Descripción</th>
              <th style="width: 160px;">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="grupo in grupos" :key="grupo.id" :class="{'table-active': selectedId === grupo.id}">
              <td>{{ grupo.id }}</td>
              <td>{{ grupo.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-info mr-2" @click="onEdit(grupo)" :disabled="formMode !== ''">Modificar</button>
                <button class="btn btn-sm btn-danger" @click="onDelete(grupo)" :disabled="formMode !== ''">Eliminar</button>
              </td>
            </tr>
            <tr v-if="grupos.length === 0">
              <td colspan="3" class="text-center">No hay grupos encontrados.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="formMode !== ''" class="card mb-3">
      <div class="card-body">
        <h5 v-if="formMode === 'add'">Agregar Grupo de Anuncio</h5>
        <h5 v-if="formMode === 'edit'">Modificar Grupo de Anuncio</h5>
        <form @submit.prevent="onSubmit">
          <div class="form-group row">
            <label class="col-sm-2 col-form-label">ID</label>
            <div class="col-sm-2">
              <input type="text" class="form-control" v-model="form.id" :readonly="true" />
            </div>
          </div>
          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Descripción</label>
            <div class="col-sm-8">
              <input type="text" class="form-control" v-model="form.descripcion" required maxlength="255" style="text-transform:uppercase" @input="form.descripcion = form.descripcion.toUpperCase()" />
            </div>
          </div>
          <div class="form-group row">
            <div class="col-sm-10">
              <button type="submit" class="btn btn-success mr-2">Aceptar</button>
              <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="alert.message" class="alert" :class="{'alert-success': alert.type==='success', 'alert-danger': alert.type==='error'}" role="alert">
      {{ alert.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'GruposAnunciosPage',
  data() {
    return {
      grupos: [],
      search: {
        descripcion: ''
      },
      form: {
        id: '',
        descripcion: ''
      },
      formMode: '', // '', 'add', 'edit'
      selectedId: null,
      alert: {
        message: '',
        type: ''
      }
    };
  },
  mounted() {
    this.fetchGrupos();
  },
  methods: {
    async fetchGrupos() {
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'anuncios_grupos_list',
            params: {
              descripcion: this.search.descripcion
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.grupos = data.eResponse.data;
        } else {
          this.grupos = [];
        }
      } catch (err) {
        this.grupos = [];
      }
    },
    onSearch() {
      this.fetchGrupos();
    },
    onAdd() {
      this.formMode = 'add';
      this.form = {
        id: '',
        descripcion: ''
      };
      this.selectedId = null;
      this.alert = { message: '', type: '' };
    },
    onEdit(grupo) {
      this.formMode = 'edit';
      this.form = {
        id: grupo.id,
        descripcion: grupo.descripcion
      };
      this.selectedId = grupo.id;
      this.alert = { message: '', type: '' };
    },
    async onDelete(grupo) {
      if (!confirm('¿Está seguro de eliminar el grupo seleccionado?')) return;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'anuncios_grupos_delete',
            params: { id: grupo.id }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.alert = { message: 'Grupo eliminado correctamente.', type: 'success' };
          this.fetchGrupos();
        } else {
          this.alert = { message: data.eResponse.message || 'Error al eliminar.', type: 'error' };
        }
      } catch (err) {
        this.alert = { message: 'Error de red al eliminar.', type: 'error' };
      }
    },
    async onSubmit() {
      if (!this.form.descripcion.trim()) {
        this.alert = { message: 'La descripción es obligatoria.', type: 'error' };
        return;
      }
      if (this.formMode === 'add') {
        // Insert
        try {
          const response = await fetch('/api/execute', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: JSON.stringify({
              eRequest: 'anuncios_grupos_insert',
              params: {
                descripcion: this.form.descripcion
              }
            })
          });
          const data = await response.json();
          if (data.eResponse.success) {
            this.alert = { message: 'Grupo agregado correctamente.', type: 'success' };
            this.formMode = '';
            this.fetchGrupos();
          } else {
            this.alert = { message: data.eResponse.message || 'Error al agregar.', type: 'error' };
          }
        } catch (err) {
          this.alert = { message: 'Error de red al agregar.', type: 'error' };
        }
      } else if (this.formMode === 'edit') {
        // Update
        try {
          const response = await fetch('/api/execute', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            },
            body: JSON.stringify({
              eRequest: 'anuncios_grupos_update',
              params: {
                id: this.form.id,
                descripcion: this.form.descripcion
              }
            })
          });
          const data = await response.json();
          if (data.eResponse.success) {
            this.alert = { message: 'Grupo modificado correctamente.', type: 'success' };
            this.formMode = '';
            this.fetchGrupos();
          } else {
            this.alert = { message: data.eResponse.message || 'Error al modificar.', type: 'error' };
          }
        } catch (err) {
          this.alert = { message: 'Error de red al modificar.', type: 'error' };
        }
      }
    },
    onCancel() {
      this.formMode = '';
      this.selectedId = null;
      this.alert = { message: '', type: '' };
    }
  }
};
</script>

<style scoped>
.table-active {
  background-color: #f5f5f5;
}
</style>
