<template>
  <div class="aut-carga-pagos-mtto-page">
    <h1>Autorizar Fecha de Ingreso</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Autorizar Fecha de Ingreso
    </div>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="fecha_ingreso">Fecha Ingreso</label>
        <input type="date" v-model="form.fecha_ingreso" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="autorizar">Permiso</label>
        <select v-model="form.autorizar" class="form-control" required>
          <option value="S">AUTORIZAR FECHA</option>
          <option value="N">BLOQUEAR FECHA</option>
        </select>
      </div>
      <div class="form-group">
        <label for="fecha_limite">Fecha Límite</label>
        <input type="date" v-model="form.fecha_limite" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="id_usupermiso">Usuario Permiso</label>
        <select v-model="form.id_usupermiso" class="form-control" required>
          <option value="">Seleccione un usuario...</option>
          <option v-for="user in users" :key="user.id_usuario" :value="user.id_usuario">
            {{ user.nombre }}
          </option>
        </select>
      </div>
      <div class="form-group">
        <label for="comentarios">Comentario</label>
        <textarea v-model="form.comentarios" @input="toUpperCase" rows="4" class="form-control"></textarea>
      </div>
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">Aceptar</button>
        <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
      </div>
    </form>
    <hr />
    <h2>Fechas Autorizadas</h2>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Fecha Ingreso</th>
          <th>Permiso</th>
          <th>Fecha Límite</th>
          <th>Usuario Permiso</th>
          <th>Comentario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in fechas" :key="item.fecha_ingreso">
          <td>{{ item.fecha_ingreso }}</td>
          <td>{{ item.autorizar === 'S' ? 'AUTORIZAR' : 'BLOQUEAR' }}</td>
          <td>{{ item.fecha_limite }}</td>
          <td>{{ item.nombre }}</td>
          <td>{{ item.comentarios }}</td>
          <td>
            <button @click="onEdit(item)" class="btn btn-sm btn-warning">Editar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="success" class="alert alert-success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'AutCargaPagosMttoPage',
  data() {
    return {
      form: {
        fecha_ingreso: '',
        autorizar: 'S',
        fecha_limite: '',
        id_usupermiso: '',
        comentarios: ''
      },
      users: [],
      fechas: [],
      editing: false,
      oficina: null, // Puede venir de store o props
      error: '',
      success: ''
    };
  },
  created() {
    // Suponiendo que la oficina viene del usuario autenticado
    this.oficina = 1; // Valor por defecto sin store
    this.loadUsers();
    this.loadFechas();
  },
  methods: {
    async loadUsers() {
      // Simulamos datos de usuarios
      setTimeout(() => {
        this.users = [
          { id_usuario: 1, nombre: 'Juan Pérez' },
          { id_usuario: 2, nombre: 'María García' },
          { id_usuario: 3, nombre: 'Carlos López' }
        ];
      }, 200);
    },
    async loadFechas() {
      // Simulamos datos de fechas autorizadas
      setTimeout(() => {
        this.fechas = [
          {
            fecha_ingreso: '2024-01-15',
            autorizar: 'S',
            fecha_limite: '2024-01-30',
            nombre: 'Juan Pérez',
            comentarios: 'AUTORIZACIÓN MENSUAL PARA PAGOS DE LOCALES'
          },
          {
            fecha_ingreso: '2024-01-10',
            autorizar: 'N', 
            fecha_limite: '2024-01-25',
            nombre: 'María García',
            comentarios: 'FECHA BLOQUEADA PARA REVISIÓN'
          }
        ];
      }, 300);
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      // Validación básica
      if (!this.form.fecha_ingreso || !this.form.fecha_limite || !this.form.id_usupermiso) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      
      // Simulamos el envío
      setTimeout(() => {
        const userName = this.users.find(u => u.id_usuario == this.form.id_usupermiso)?.nombre || 'Usuario';
        
        if (this.editing) {
          // Actualizar registro existente
          const index = this.fechas.findIndex(f => f.fecha_ingreso === this.form.fecha_ingreso);
          if (index !== -1) {
            this.fechas[index] = {
              ...this.form,
              nombre: userName
            };
          }
          this.success = 'Actualizado correctamente';
        } else {
          // Agregar nuevo registro
          this.fechas.push({
            ...this.form,
            nombre: userName
          });
          this.success = 'Registrado correctamente';
        }
        
        this.onCancel();
      }, 500);
    },
    onEdit(item) {
      this.form = {
        fecha_ingreso: item.fecha_ingreso,
        autorizar: item.autorizar,
        fecha_limite: item.fecha_limite,
        id_usupermiso: item.id_usupermiso,
        comentarios: item.comentarios
      };
      this.editing = true;
      this.success = '';
      this.error = '';
    },
    onCancel() {
      this.form = {
        fecha_ingreso: '',
        autorizar: 'S',
        fecha_limite: '',
        id_usupermiso: '',
        comentarios: ''
      };
      this.editing = false;
      this.error = '';
      this.success = '';
    },
    toUpperCase(e) {
      this.form.comentarios = this.form.comentarios.toUpperCase();
    }
  }
};
</script>

<style scoped>
.aut-carga-pagos-mtto-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.form-group {
  margin-bottom: 1rem;
}
.form-actions {
  margin-top: 1rem;
}
.table {
  width: 100%;
  margin-top: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.9em;
}
.alert {
  margin-top: 1rem;
}
</style>
