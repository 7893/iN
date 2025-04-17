// 类型定义
interface TaskStatus {
    id: string;
    status: 'pending' | 'processing' | 'completed' | 'failed';
    progress?: number;
    message?: string;
}

// API 端点配置
const API_CONFIG = {
    UPLOAD: '/api/upload',
    TASK_STATUS: '/api/task-status',
};

// 主要功能
class ImageProcessor {
    private taskList: Map<string, TaskStatus> = new Map();

    constructor() {
        this.initializeEventListeners();
    }

    private initializeEventListeners() {
        // 上传按钮事件
        const uploadBtn = document.getElementById('uploadBtn');
        uploadBtn?.addEventListener('click', () => this.handleUpload());

        // 文件输入事件
        const imageInput = document.getElementById('imageInput') as HTMLInputElement;
        imageInput?.addEventListener('change', () => {
            if (imageInput.files && imageInput.files.length > 0) {
                uploadBtn?.removeAttribute('disabled');
            } else {
                uploadBtn?.setAttribute('disabled', 'true');
            }
        });
    }

    private async handleUpload() {
        const imageInput = document.getElementById('imageInput') as HTMLInputElement;
        if (!imageInput.files || imageInput.files.length === 0) return;

        const files = Array.from(imageInput.files);
        
        try {
            for (const file of files) {
                // 创建 FormData
                const formData = new FormData();
                formData.append('image', file);

                // 发送请求
                const response = await fetch(API_CONFIG.UPLOAD, {
                    method: 'POST',
                    body: formData
                });

                if (!response.ok) throw new Error('Upload failed');

                const { taskId } = await response.json();
                
                // 添加任务到列表
                this.addTask(taskId);
                
                // 开始轮询任务状态
                this.pollTaskStatus(taskId);
            }
        } catch (error) {
            this.updateStatus(`上传失败: ${error.message}`);
        }
    }

    private addTask(taskId: string) {
        this.taskList.set(taskId, { id: taskId, status: 'pending' });
        this.updateTaskList();
    }

    private async pollTaskStatus(taskId: string) {
        while (true) {
            try {
                const response = await fetch(`${API_CONFIG.TASK_STATUS}/${taskId}`);
                if (!response.ok) throw new Error('Failed to fetch status');

                const status: TaskStatus = await response.json();
                this.taskList.set(taskId, status);
                this.updateTaskList();

                if (status.status === 'completed' || status.status === 'failed') {
                    break;
                }

                await new Promise(resolve => setTimeout(resolve, 2000)); // 2秒轮询
            } catch (error) {
                this.updateStatus(`状态查询失败: ${error.message}`);
                break;
            }
        }
    }

    private updateTaskList() {
        const taskListElement = document.getElementById('taskList');
        if (!taskListElement) return;

        taskListElement.innerHTML = '';
        
        this.taskList.forEach(task => {
            const taskElement = document.createElement('div');
            taskElement.className = 'task-item';
            taskElement.innerHTML = `
                <div>任务ID: ${task.id}</div>
                <div>状态: ${task.status}</div>
                ${task.progress ? `<div>进度: ${task.progress}%</div>` : ''}
                ${task.message ? `<div>消息: ${task.message}</div>` : ''}
            `;
            taskListElement.appendChild(taskElement);
        });
    }

    private updateStatus(message: string) {
        const statusDisplay = document.getElementById('statusDisplay');
        if (statusDisplay) {
            statusDisplay.textContent = `${new Date().toISOString()}: ${message}\n${statusDisplay.textContent}`;
        }
    }
}

// 初始化应用
new ImageProcessor();