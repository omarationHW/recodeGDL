<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Claves de Diferencias por Cobrar</h1>
        <p>Mercados - Claves de Diferencias por Cobrar</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="card mb-4">
      <div class="municipal-card-header">
        <h5>Mantenimiento Claves de Diferencias por Cobrar</h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="clave_diferencia" class="municipal-form-label">Clave Diferencia</label>
              <input type="number" class="municipal-form-control" id="clave_diferencia" v-model.number="form.clave_diferencia" :disabled="formMode==='edit'" required min="1" max="5000">
            </div>
            <div class="col-md-6">
              <label for="descripcion" class="municipal-form-label">Descripción de la Clave</label>
              <input type="text" class="municipal-form-control" id="descripcion" v-model="form.descripcion" maxlength="60" required style="text-transform:uppercase">
            </div>
            <div class="col-md-2">
              <label for="cuenta_ingreso" class="municipal-form-label">Cuenta Ingreso</label>
              <input type="number" class="municipal-form-control" id="cuenta_ingreso" v-model.number="form.cuenta_ingreso" required min="1" max="999999">
            </div>
            <div class="col-md-2">
              <label for="id_usuario" class="municipal-form-label">Usuario</label>
              <input type="number" class="municipal-form-control" id="id_usuario" v-model.number="form.id_usuario" required>
            </div>
          </div>
          <div class="row mb-2">
            <div class="col-md-12">
              <label class="municipal-form-label">Catálogo de Cuentas</label>
              <table class="table table-sm table-bordered table-hover">
                <thead>
                  <tr>
                    <th>Cuenta</th>
                    <th>Descripción</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="cuenta in cuentas" :key="cuenta.cta_aplicacion" @click="selectCuenta(cuenta.cta_aplicacion)" :class="{'table-active': form.cuenta_ingreso === cuenta.cta_aplicacion}">
                    <td>{{ cuenta.cta_aplicacion }}</td>
                    <td>{{ cuenta.descripcion }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-md-12 text-end">
              <button type="submit" class="btn btn-primary me-2">{{ formMode==='edit' ? 'Actualizar' : 'Agregar' }}</button>
              <button type="button" class="btn-municipal-secondary" @click="resetForm">Cancelar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h6>Listado de Claves de Diferencias</h6>
      </div>
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Clave</th>
              <th>Descripción</th>
              <th>Cuenta Ingreso</th>
              <th>Fecha Actualización</th>
              <th>Usuario</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in lista" :key="item.clave_diferencia">
              <td>{{ item.clave_diferencia }}</td>
              <td>{{ item.descripcion }}</td>
              <td>{{ item.cuenta_ingreso }}</td>
              <td>{{ item.fecha_actual ? (item.fecha_actual.substr(0,19).replace('T',' ')) : '' }}</td>
              <td>{{ item.id_usuario }}</td>
              <td>
                <button class="btn btn-sm btn-outline-primary" @click="editItem(item)"><i class="bi bi-pencil"></i> Editar</button>
              </td>
            </tr>
            <tr v-if="lista.length===0">
              <td colspan="6" class="text-center">No hay registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="alert.message" class="alert mt-3" :class="{'alert-success': alert.success, 'alert-danger': !alert.success}">
      {{ alert.message }}
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'CveDiferMnttoPage',
  data() {
    return {
      lista: [],
      cuentas: [],
      form: {
        clave_diferencia: '',
        descripcion: '',
        cuenta_ingreso: '',
        id_usuario: ''
      },
      formMode: 'add', // 'add' | 'edit'
      alert: {
        message: '',
        success: true
      }
    }
  },
  mounted() {
    this.loadLista();
    this.loadCuentas();
  },
  methods: {
    async loadLista() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list_cve_diferencias' })
      });
      const data = await res.json();
      if (data.success) this.lista = data.data;
    },
    async loadCuentas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list_cuentas' })
      });
      const data = await res.json();
      if (data.success) this.cuentas = data.data;
    },
    selectCuenta(cta) {
      this.form.cuenta_ingreso = cta;
    },
    editItem(item) {
      this.form = {
        clave_diferencia: item.clave_diferencia,
        descripcion: item.descripcion,
        cuenta_ingreso: item.cuenta_ingreso,
        id_usuario: item.id_usuario
      };
      this.formMode = 'edit';
      this.alert.message = '';
    },
    resetForm() {
      this.form = {
        clave_diferencia: '',
        descripcion: '',
        cuenta_ingreso: '',
        id_usuario: ''
      };
      this.formMode = 'add';
      this.alert.message = '';
    },
    async onSubmit() {
      if (!this.form.descripcion) {
        this.alert = { message: 'La descripción no puede ser nula', success: false };
        return;
      }
      if (!this.form.cuenta_ingreso) {
        this.alert = { message: 'La cuenta de ingreso no puede ser nula', success: false };
        return;
      }
      if (!this.form.id_usuario) {
        this.alert = { message: 'El usuario es obligatorio', success: false };
        return;
      }
      let action = this.formMode === 'edit' ? 'update_cve_diferencia' : 'insert_cve_diferencia';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action,
          params: {
            clave_diferencia: this.form.clave_diferencia,
            descripcion: this.form.descripcion.toUpperCase(),
            cuenta_ingreso: this.form.cuenta_ingreso,
            id_usuario: this.form.id_usuario
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.alert = { message: data.message || 'Guardado correctamente', success: true };
        this.loadLista();
        this.resetForm();
      } else {
        this.alert = { message: data.message || 'Error al guardar', success: false };
      }
    }
  }
}
</script>

<style scoped>
.cve-difer-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.table-active {
  background-color: #e9ecef;
}
</style>
